head(air_data)
getwd()
str(air_data)
dim(air_data)
summary(air_data)
sum(is.na(air_data))
before <- c(925, 718, 935, 1023, 20, 14, 81)
after  <- c(0, 0, 0, 0, 0, 0, 0)

barplot(
  rbind(before, after),
  beside = TRUE,
  names.arg = c("PM2.5","PM10","SO2","NO2","TEMP","WSPM","wd"),
  col = c("red","green"),
  legend.text = c("Before","After"),
  main = "Missing Values Before and After Cleaning",
  xlab = "Variables",
  ylab = "Number of Missing Values"
)
#################################################
# TASK 2 : NA, NULL and NaN
#################################################

temperature <- c(28, 30, NA, 32)

cat("Temperature Vector:\n")
print(temperature)

cat("\nis.na():\n")
print(is.na(temperature))


missing_object <- NULL

cat("\nNULL Object:\n")
print(missing_object)

cat("\nis.null():\n")
print(is.null(missing_object))


undefined_value <- 0/0

cat("\nNaN Value:\n")
print(undefined_value)

cat("\nis.nan():\n")
print(is.nan(undefined_value))

#################################################
# TASK 3 : Missing Summary Function
#################################################

missing_summary <- function(df){
  
  variables <- c("PM2.5","PM10","SO2","NO2","TEMP","WSPM","wd")
  
  result <- data.frame(
    Variable=character(),
    Total_Records=integer(),
    Missing_Values=integer(),
    Missing_Percentage=double()
  )
  
  for(v in variables){
    
    total <- nrow(df)
    
    missing <- sum(is.na(df[[v]]))
    
    percent <- round((missing/total)*100,2)
    
    result <- rbind(result,
                    data.frame(
                      Variable=v,
                      Total_Records=total,
                      Missing_Values=missing,
                      Missing_Percentage=percent))
    
    if(percent > 20){
      
      warning(paste(v,"contains more than 20% missing values"))
      
    }
    
  }
  
  return(result)
  
}
missing_summary(air_data)
#################################################
# TASK 4 : Identify Invalid Numerical Results
#################################################

air_data$pollution_ratio <- air_data$PM2.5 / air_data$PM10
cat("Number of NA values:", sum(is.na(air_data$pollution_ratio)), "\n")

cat("Number of NaN values:", sum(is.nan(air_data$pollution_ratio)), "\n")

cat("Number of Infinite values:", sum(is.infinite(air_data$pollution_ratio)), "\n")

air_data$pollution_ratio[is.nan(air_data$pollution_ratio)] <- NA

air_data$pollution_ratio[is.infinite(air_data$pollution_ratio)] <- NA

cat("NaN after replacement:", sum(is.nan(air_data$pollution_ratio)), "\n")

cat("Infinite after replacement:", sum(is.infinite(air_data$pollution_ratio)), "\n")

#################################################
# TASK 5 : Handle Missing Numerical Values
#################################################

numeric_variables <- c("PM2.5", "PM10", "SO2", "NO2", "TEMP", "WSPM")

for(v in numeric_variables){
  
  if(v %in% names(air_data)){
    
    missing_before <- sum(is.na(air_data[[v]]))
    
    median_value <- median(air_data[[v]], na.rm = TRUE)
    
    air_data[[v]][is.na(air_data[[v]])] <- median_value
    
    missing_after <- sum(is.na(air_data[[v]]))
    
    cat("\n---------------------------\n")
    cat("Variable:", v, "\n")
    cat("Missing Before:", missing_before, "\n")
    cat("Median Used:", median_value, "\n")
    cat("Missing After:", missing_after, "\n")
  }
}

#################################################
# TASK 6 : Handle Missing Categorical Values
#################################################

calculate_mode <- function(x){
  
  unique_values <- unique(x)
  
  unique_values <- unique_values[!is.na(unique_values)]
  
  mode_value <- unique_values[
    which.max(tabulate(match(x, unique_values)))
  ]
  
  return(mode_value)
  
}

before_wd <- sum(is.na(air_data$wd))

mode_wd <- calculate_mode(air_data$wd)

air_data$wd[is.na(air_data$wd)] <- mode_wd

after_wd <- sum(is.na(air_data$wd))

cat("\nMode of wd:", mode_wd, "\n")
cat("Missing Before:", before_wd, "\n")
cat("Missing After:", after_wd, "\n")


#################################################
# TASK 7 : Error Handling Function
#################################################

clean_variable <- function(df, varname){
  
  tryCatch({
    
    if(!(varname %in% names(df)))
      stop("Variable does not exist.")
    
    if(!is.numeric(df[[varname]]))
      stop("Variable is not numerical.")
    
    if(all(is.na(df[[varname]])))
      stop("Variable contains only missing values.")
    
    med <- median(df[[varname]], na.rm = TRUE)
    
    if(is.na(med))
      stop("Median cannot be calculated.")
    
    df[[varname]][is.na(df[[varname]])] <- med
    
    cat(varname, "cleaned successfully.\n")
    
    return(df[[varname]])
    
  },
  
  error = function(e){
    
    cat("Error:", e$message, "\n")
    
  })
  
}

clean_variable(air_data, "PM2.5")
clean_variable(air_data, "wd")
clean_variable(air_data, "ABC")


#################################################
# TASK 8 : Comparison Table
#################################################
summary_before <- missing_summary(air_data)
variables <- c("PM2.5","PM10","SO2","NO2","TEMP","WSPM","wd")

before <- summary_before$Missing_Values

after <- c()

for(v in variables){
  
  after <- c(after, sum(is.na(air_data[[v]])))
  
}

comparison_table <- data.frame(
  
  Variable = variables,
  
  Missing_Before = before,
  
  Missing_After = after,
  
  Values_Replaced = before - after
  
)

print(comparison_table)

#################################################
# TASK 10 : Export Cleaned Dataset
#################################################

write.csv(
  air_data,
  "cleaned_air_quality_data.csv",
  row.names = FALSE
)

cat("Cleaned dataset exported successfully.\n")

summary_before <- missing_summary(air_data)
print(summary_before)
print(comparison_table)
