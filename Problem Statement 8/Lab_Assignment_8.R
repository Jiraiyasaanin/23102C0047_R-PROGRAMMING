
options(stringsAsFactors = FALSE, scipen = 999)
set.seed(123)

# ---------- 1. Install and load packages ----------
required_packages <- c(
  "data.table", "arrow", "ggplot2", "lubridate",
  "foreach", "doParallel", "microbenchmark", "purrr"
)
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages)) {
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}
invisible(lapply(required_packages, library, character.only = TRUE))

# ---------- 2. Output and data folders ----------
output_dir <- "lab8_outputs"
data_dir <- file.path(output_dir, "data")
plot_dir <- file.path(output_dir, "plots")
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)

# January 2025 is a fixed, reproducible month with millions of trips.
# URLs are from NYC TLC's public trip-data distribution.
trip_url <- "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2025-01.parquet"
zone_url <- "https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv"
trip_file <- file.path(data_dir, "yellow_tripdata_2025-01.parquet")
zone_file <- file.path(data_dir, "taxi_zone_lookup.csv")

download_if_missing <- function(url, dest) {
  if (!file.exists(dest)) {
    message("Downloading: ", basename(dest))
    tryCatch(
      download.file(url, destfile = dest, mode = "wb", quiet = FALSE),
      error = function(e) stop("Download failed for ", url, "\n", conditionMessage(e))
    )
  }
  if (!file.exists(dest) || file.info(dest)$size == 0) {
    stop("Downloaded file is missing or empty: ", dest)
  }
}
download_if_missing(trip_url, trip_file)
download_if_missing(zone_url, zone_file)

# ---------- 3. Import and inspect ----------
message("Reading parquet file. This may take a few minutes.")
trips <- data.table::as.data.table(arrow::read_parquet(trip_file))
zones <- data.table::fread(zone_file)

writeLines(capture.output(str(trips)), file.path(output_dir, "dataset_structure.txt"))
write.csv(data.frame(
  rows = nrow(trips),
  columns = ncol(trips),
  file_size_MB = round(file.info(trip_file)$size / 1024^2, 2)
), file.path(output_dir, "dataset_dimensions.csv"), row.names = FALSE)

cat("\n--- Initial dimensions ---\n")
print(dim(trips))
cat("\n--- Initial summary ---\n")
print(summary(trips))

# Use only columns needed for this analysis, when available.
wanted <- c(
  "VendorID", "tpep_pickup_datetime", "tpep_dropoff_datetime",
  "passenger_count", "trip_distance", "RatecodeID",
  "PULocationID", "DOLocationID", "payment_type",
  "fare_amount", "tip_amount", "tolls_amount", "total_amount"
)
wanted <- intersect(wanted, names(trips))
trips <- trips[, ..wanted]

# ---------- 4. Clean data and derive temporal attributes ----------
before_rows <- nrow(trips)
trips <- unique(trips)
after_dedup <- nrow(trips)

# Standardize datetime columns and remove records with invalid key values.
trips[, pickup_datetime := as.POSIXct(tpep_pickup_datetime, tz = "UTC")]
trips[, dropoff_datetime := as.POSIXct(tpep_dropoff_datetime, tz = "UTC")]

trips <- trips[
  !is.na(pickup_datetime) &
  !is.na(dropoff_datetime) &
  dropoff_datetime >= pickup_datetime &
  !is.na(trip_distance) & trip_distance > 0 &
  !is.na(fare_amount) & fare_amount >= 0 &
  !is.na(total_amount) & total_amount >= 0 &
  !is.na(PULocationID) & !is.na(DOLocationID)
]

# Keep missing passenger counts as NA rather than assuming a value.
trips[, `:=`(
  hour = lubridate::hour(pickup_datetime),
  day = lubridate::day(pickup_datetime),
  weekday = factor(
    lubridate::wday(pickup_datetime, label = TRUE, abbr = FALSE, week_start = 1),
    levels = c("Monday", "Tuesday", "Wednesday", "Thursday",
               "Friday", "Saturday", "Sunday")
  ),
  month = lubridate::month(pickup_datetime, label = TRUE, abbr = TRUE),
  pickup_date = as.Date(pickup_datetime)
)]

cleaning_summary <- data.frame(
  stage = c("Rows imported", "After duplicate removal", "After validity filters"),
  rows = c(before_rows, after_dedup, nrow(trips))
)
write.csv(cleaning_summary, file.path(output_dir, "cleaning_summary.csv"), row.names = FALSE)

# ---------- 5. Join pickup and drop-off zone information ----------
zones <- data.table::as.data.table(zones)
if (!("LocationID" %in% names(zones))) stop("Zone lookup lacks LocationID.")
setkey(zones, LocationID)

pickup_zones <- copy(zones)
setnames(pickup_zones,
         old = intersect(c("LocationID", "Borough", "Zone"), names(pickup_zones)),
         new = paste0("PU_", intersect(c("LocationID", "Borough", "Zone"), names(pickup_zones))))
dropoff_zones <- copy(zones)
setnames(dropoff_zones,
         old = intersect(c("LocationID", "Borough", "Zone"), names(dropoff_zones)),
         new = paste0("DO_", intersect(c("LocationID", "Borough", "Zone"), names(dropoff_zones))))

trips <- merge(trips, pickup_zones, by.x = "PULocationID", by.y = "PU_LocationID", all.x = TRUE)
trips <- merge(trips, dropoff_zones, by.x = "DOLocationID", by.y = "DO_LocationID", all.x = TRUE)

# ---------- 6. Analytics using data.table ----------
trips_by_hour <- trips[, .(trip_count = .N, mean_fare = mean(fare_amount, na.rm = TRUE)),
                       by = hour][order(hour)]
trips_by_weekday <- trips[, .(trip_count = .N, total_revenue = sum(total_amount, na.rm = TRUE)),
                          by = weekday][order(weekday)]
trips_by_month <- trips[, .(trip_count = .N, total_revenue = sum(total_amount, na.rm = TRUE),
                            mean_fare = mean(fare_amount, na.rm = TRUE)),
                        by = month][order(month)]
routes <- trips[, .(
  trip_count = .N,
  total_revenue = sum(total_amount, na.rm = TRUE),
  average_fare = mean(fare_amount, na.rm = TRUE),
  average_distance = mean(trip_distance, na.rm = TRUE)
), by = .(PULocationID, DOLocationID)]
setorder(routes, -trip_count)
top_routes_frequency <- head(routes, 15)
top_routes_revenue <- routes[order(-total_revenue)][1:min(15L, .N)]
distance_fare <- trips[, .(
  trip_count = .N,
  average_fare = mean(fare_amount, na.rm = TRUE),
  median_fare = median(fare_amount, na.rm = TRUE)
), by = .(distance_band = cut(
  trip_distance,
  breaks = c(0, 1, 2, 3, 5, 10, 20, Inf),
  labels = c("0-1", "1-2", "2-3", "3-5", "5-10", "10-20", "20+"),
  include.lowest = TRUE
))]
payment_summary <- trips[, .(
  trip_count = .N,
  total_revenue = sum(total_amount, na.rm = TRUE)
), by = .(payment_type, PU_Borough)][order(-trip_count)]

# Write analytical tables.
tables <- list(
  trips_by_hour = trips_by_hour,
  trips_by_weekday = trips_by_weekday,
  trips_by_month = trips_by_month,
  top_routes_frequency = top_routes_frequency,
  top_routes_revenue = top_routes_revenue,
  distance_fare = distance_fare,
  payment_summary = payment_summary
)
for (nm in names(tables)) {
  data.table::fwrite(tables[[nm]], file.path(output_dir, paste0(nm, ".csv")))
}

# ---------- 7. Functional, vectorized, and data.table comparisons ----------
# The same task: count records by pickup hour.
hour_vectorized <- function(x) {
  tab <- tabulate(x$hour + 1L, nbins = 24L)
  data.table(hour = 0:23, trip_count = tab)
}
hour_apply <- function(x) {
  counts <- sapply(0:23, function(h) sum(x$hour == h, na.rm = TRUE))
  data.table(hour = 0:23, trip_count = as.integer(counts))
}
hour_lapply <- function(x) {
  counts <- unlist(lapply(0:23, function(h) sum(x$hour == h, na.rm = TRUE)))
  data.table(hour = 0:23, trip_count = as.integer(counts))
}
hour_purrr <- function(x) {
  counts <- purrr::map_int(0:23, ~sum(x$hour == .x, na.rm = TRUE))
  data.table(hour = 0:23, trip_count = counts)
}
hour_datatable <- function(x) {
  x[, .(trip_count = .N), by = hour][order(hour)]
}

# Verify equivalent results before comparing performance.
reference <- hour_datatable(trips)
stopifnot(identical(reference$trip_count, hour_vectorized(trips)$trip_count))
stopifnot(identical(reference$trip_count, hour_apply(trips)$trip_count))
stopifnot(identical(reference$trip_count, hour_lapply(trips)$trip_count))
stopifnot(identical(reference$trip_count, hour_purrr(trips)$trip_count))

# Benchmark on a reproducible sample to keep repeated runs practical.
bench_n <- min(250000L, nrow(trips))
bench_data <- trips[seq_len(bench_n), .(hour)]
bench <- microbenchmark::microbenchmark(
  vectorized = hour_vectorized(bench_data),
  apply = hour_apply(bench_data),
  lapply = hour_lapply(bench_data),
  purrr_map = hour_purrr(bench_data),
  data_table = hour_datatable(bench_data),
  times = 5L
)
bench_summary <- as.data.frame(summary(bench)[, c("expr", "min", "median", "mean", "max")])
bench_summary[, c("min", "median", "mean", "max")] <-
  lapply(bench_summary[, c("min", "median", "mean", "max")], function(x) x / 1e9)
names(bench_summary)[2:5] <- c("min_seconds", "median_seconds", "mean_seconds", "max_seconds")
write.csv(bench_summary, file.path(output_dir, "benchmark_functional_vs_optimized.csv"), row.names = FALSE)

# ---------- 8. Sequential vs parallel computation ----------
# Independent month partitions are demonstrated by grouping on pickup month.
# With one month of source data, this still gives a repeatable partitioned task
# using day-of-month partitions; it avoids pretending that multiple months exist.
trips[, day_partition := lubridate::day(pickup_datetime)]
partitions <- sort(unique(trips$day_partition))
partition_task <- function(day_value) {
  z <- trips[day_partition == day_value]
  z[, .(trip_count = .N, total_revenue = sum(total_amount, na.rm = TRUE)),
    by = .(hour)]
}

seq_time <- system.time({
  seq_results <- lapply(partitions, partition_task)
})[["elapsed"]]

available_cores <- parallel::detectCores(logical = TRUE)
if (is.na(available_cores)) available_cores <- 2L
workers <- max(1L, min(4L, available_cores - 1L, length(partitions)))
cl <- parallel::makeCluster(workers)
doParallel::registerDoParallel(cl)

parallel_time <- system.time({
  parallel_results <- foreach::foreach(
    d = partitions, .combine = "rbind",
    .packages = "data.table"
  ) %dopar% {
    z <- trips[day_partition == d]
    z[, .(partition_day = d, trip_count = .N,
          total_revenue = sum(total_amount, na.rm = TRUE)), by = .(hour)]
  }
})[["elapsed"]]

parallel::stopCluster(cl)
foreach::registerDoSEQ()

speedup <- if (parallel_time > 0) seq_time / parallel_time else NA_real_
parallel_summary <- data.frame(
  method = c("Sequential lapply", "Parallel foreach/doParallel"),
  elapsed_seconds = c(seq_time, parallel_time),
  workers = c(1L, workers),
  speedup_sequential_over_parallel = c(1, speedup)
)
write.csv(parallel_summary, file.path(output_dir, "benchmark_sequential_vs_parallel.csv"), row.names = FALSE)
trips[, day_partition := NULL]

# ---------- 9. Visualizations ----------
p1 <- ggplot2::ggplot(trips_by_hour, ggplot2::aes(hour, trip_count)) +
  ggplot2::geom_line() + ggplot2::geom_point() +
  ggplot2::scale_x_continuous(breaks = 0:23) +
  ggplot2::labs(title = "NYC Yellow Taxi Trips by Pickup Hour",
                x = "Pickup hour (0–23)", y = "Number of trips") +
  ggplot2::theme_minimal()
ggplot2::ggsave(file.path(plot_dir, "trips_by_hour.png"), p1, width = 9, height = 5, dpi = 150)

p2 <- ggplot2::ggplot(trips_by_weekday, ggplot2::aes(weekday, trip_count)) +
  ggplot2::geom_col() +
  ggplot2::labs(title = "Taxi Demand by Day of Week", x = "Day of week", y = "Number of trips") +
  ggplot2::theme_minimal()
ggplot2::ggsave(file.path(plot_dir, "trips_by_weekday.png"), p2, width = 9, height = 5, dpi = 150)

p3 <- ggplot2::ggplot(distance_fare, ggplot2::aes(distance_band, average_fare)) +
  ggplot2::geom_col() +
  ggplot2::labs(title = "Average Fare by Trip-Distance Band",
                x = "Trip distance (miles)", y = "Average fare (USD)") +
  ggplot2::theme_minimal()
ggplot2::ggsave(file.path(plot_dir, "average_fare_by_distance.png"), p3, width = 9, height = 5, dpi = 150)

p4 <- ggplot2::ggplot(payment_summary[!is.na(PU_Borough)],
                       ggplot2::aes(x = factor(payment_type), y = trip_count, fill = PU_Borough)) +
  ggplot2::geom_col() +
  ggplot2::labs(title = "Payment Type by Pickup Borough",
                x = "Payment type code", y = "Number of trips", fill = "Pickup borough") +
  ggplot2::theme_minimal()
ggplot2::ggsave(file.path(plot_dir, "payment_by_borough.png"), p4, width = 9, height = 5, dpi = 150)

# Top routes plot, using IDs so it works even if some zones are unmapped.
top_routes_frequency[, route := paste0(PULocationID, " → ", DOLocationID)]
p5 <- ggplot2::ggplot(top_routes_frequency, ggplot2::aes(
  x = reorder(route, trip_count), y = trip_count)) +
  ggplot2::geom_col() + ggplot2::coord_flip() +
  ggplot2::labs(title = "15 Most Frequently Travelled Routes",
                x = "Pickup Location ID → Drop-off Location ID", y = "Number of trips") +
  ggplot2::theme_minimal()
ggplot2::ggsave(file.path(plot_dir, "top_routes_frequency.png"), p5, width = 10, height = 6, dpi = 150)

# ---------- 10. Automatically generated observations ----------
peak_hour <- trips_by_hour[which.max(trip_count)]
peak_weekday <- trips_by_weekday[which.max(trip_count)]
top_frequency <- top_routes_frequency[1]
top_revenue <- top_routes_revenue[1]
fastest_benchmark <- bench_summary[which.min(bench_summary$median_seconds), ]
fastest_parallel_method <- parallel_summary$method[which.min(parallel_summary$elapsed_seconds)]

observations <- c(
  "LAB 8: High-Performance Big Data Analytics Using R",
  paste0("Valid records analyzed: ", format(nrow(trips), big.mark = ",")),
  paste0("Peak pickup hour: ", peak_hour$hour, ":00 (", format(peak_hour$trip_count, big.mark = ","), " trips)."),
  paste0("Highest-demand weekday: ", as.character(peak_weekday$weekday),
         " (", format(peak_weekday$trip_count, big.mark = ","), " trips)."),
  paste0("Most frequent route by Location IDs: ", top_frequency$PULocationID, " -> ",
         top_frequency$DOLocationID, " (", format(top_frequency$trip_count, big.mark = ","), " trips)."),
  paste0("Highest-revenue route by Location IDs: ", top_revenue$PULocationID, " -> ",
         top_revenue$DOLocationID, " (USD ", round(top_revenue$total_revenue, 2), ")."),
  paste0("Fastest median benchmark implementation on sample: ", fastest_benchmark$expr,
         " (", signif(fastest_benchmark$median_seconds, 4), " seconds)."),
  paste0("Sequential time: ", seq_time, " seconds; parallel time: ", parallel_time,
         " seconds; measured speedup: ", round(speedup, 3), "x."),
  "",
  "Interpretation notes:",
  "- data.table is designed for fast grouped operations, joins, and by-reference updates.",
  "- Vectorized operations can be very fast for simple calculations because they avoid repeated R-level loops.",
  "- apply/lapply/purrr improve code structure for repeated operations, but do not automatically make code faster.",
  "- Parallel processing can be slower for small tasks because worker startup, data transfer, and coordination add overhead.",
  "- This file uses one monthly dataset; monthly trend conclusions require downloading and combining multiple months."
)
writeLines(observations, file.path(output_dir, "observations_and_conclusion.txt"))

# Save a concise reproducibility record.
capture.output(sessionInfo(), file = file.path(output_dir, "session_info.txt"))
cat("\nAnalysis completed.\n")
cat("Outputs saved to: ", normalizePath(output_dir), "\n", sep = "")
cat("Read observations_and_conclusion.txt and the CSV files before final submission.\n")
