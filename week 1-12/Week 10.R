

y <- "Number of participants: 25"
sub("25", "30", y)

y <- "Mr. Singh is the smart one. Mr. Singh is funny, too."
sub("Mr. Singh", "Professor Jha", y)



y <- "Mr. Singh is the smart one. Mr. Singh is funny, too."
gsub("Mr. Singh", "Professor Jha", y)




str <- c("R Course", "exercises", "include examples of R language")

grep("ex", str)

# value = TRUE gives the matching strings
grep("ex", str, value = TRUE)

# value = FALSE gives the positions
grep("ex", str, value = FALSE)


# ============================================================
# 4. grep() with ignore.case
# ============================================================

str <- c(
  "R Course",
  "exercises",
  "include examples of r language",
  "in R software."
)

grep("R", str, ignore.case = FALSE, value = TRUE)
grep("R", str, ignore.case = TRUE, value = TRUE)

grep("R", str, ignore.case = FALSE, value = FALSE)
grep("R", str, ignore.case = TRUE, value = FALSE)


# ============================================================
# 5. grep() with two strings
# ============================================================

x <- "R course 24.07.2021"
y <- "Number of participants: 25"

c(x, y)
grep("our", c(x, y))
grep("Num", c(x, y))


# ============================================================
# 6. grepl() - returns TRUE/FALSE
# ============================================================

str <- c("R Course", "exercises", "include examples of R language")

grepl("R", str)
grepl("ex", str)


# ============================================================
# 7. Data Frames - MASS painters dataset
# ============================================================

library(MASS)

painters

# Access columns
painters$School
painters$Drawing

# Check numeric
is.numeric(painters$School)
is.numeric(painters$Drawing)

# Check factor
is.factor(painters$School)
is.factor(painters$Drawing)

# Column names
colnames(painters)

# Summary
summary(painters)
summary(painters$School)
summary(painters$Composition)


# ============================================================
# 8. attach() and detach()
# ============================================================

attach(painters)

summary(School)
summary(Composition)

detach(painters)


# ============================================================
# 9. subset() - filter rows
# ============================================================

subset(painters, School == "F")
subset(painters, Composition <= 6)

# Select specific columns
subset(
  painters,
  School == "F",
  select = c(Composition, Drawing, Expression)
)

# Remove columns 3 and 5
subset(
  painters,
  School == "F",
  select = c(-3, -5)
)


# ============================================================
# 10. split() - split data frame by School
# ============================================================

splitted <- split(painters, painters$School)

splitted

# Individual groups
splitted$A
splitted$F

# Check whether it is a data frame
is.data.frame(splitted$A)


# ============================================================
# 11. Create df1 and df2
# ============================================================

df1 <- data.frame(
  state = c("UP", "MP", "AP", "JK"),
  popnsize = c(1000, 2000, 3000, 4000)
)

df2 <- data.frame(
  state = c("UP", "MP", "AP", "JK"),
  samplesize = c(100, 200, 300, 400),
  surveycompleted = c("Yes", "No", "Yes", "No")
)

df1
df2


# ============================================================
# 12. cbind() - combine columns
# ============================================================

cbind(df1, df2)


# ============================================================
# 13. merge() - merge using common column
# ============================================================

merge(df1, df2, by = "state")


# ============================================================
# 14. rbind() - combine rows
# ============================================================

df11 <- data.frame(
  state = c("UP", "MP", "AP", "JK"),
  popnsize = c(1000, 2000, 3000, 4000)
)

df22 <- data.frame(
  state = c("Bihar", "Delhi", "Punjab"),
  popnsize = c(100, 200, 300)
)

df11
df22

rbind(df11, df22)


# ============================================================
# QUICK REVISION
# ============================================================
# sub()   = replace FIRST occurrence
# gsub()  = replace ALL occurrences
# grep()  = find matching positions/values
# grepl() = TRUE/FALSE matching
# subset() = filter rows/columns
# split() = split data frame by a variable
# cbind() = combine columns
# rbind() = combine rows
# merge() = combine using a common column
# attach() = access data-frame columns directly
# detach() = remove attachment
