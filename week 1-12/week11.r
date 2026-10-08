library(MASS)
painters
summary(painters$School)

attach(painters)
summary(School)
summary(Composition)
detach(painters)

subset(painters, School=="F")
painters[painters[["School"]]=="F",]
subset(painters, Composition<=6)
subset(painters, School=="F", select=c(-3,-5))

splitted = split(painters, painters$School)
splitted
is.data.frame(splitted$A)

x = c(1:100)
x
write(x, file="shalabh")

gender = c(1,2,1,2,1,1,1,2,1,1)
gender
table(gender)
table(gender)/length(gender)

direction = c(1,1,2,1,2,3,2,2,3,3,3,1,2,3,2,2,3,1,1,3,3,1,2,1,3,3,3,2,2,2,2,1,2,2,1,1,1,3,2,2,1,2,3,2,2,1,2,3,3,2,1,2,2,3,1,1,2,1,2,3,2,3,2,2,3,1,2,3,3,3,2,1,1,1,2,1,1,2,1,2,3,3,1,2,3,3,2,1,2,3,2,1,3,2,2,2,2,3,2,2)
table(direction)
table(direction)/length(direction)

marks = c(68,82,63,86,34,96,41,89,29,51,75,77,56,59,42)
quantile(marks)
quantile(marks, probs=c(0,0.25,0.5,0.75,1))
quantile(marks, probs=c(0,0.20,0.4,0.6,0.8,1))

height = c(166,125,130,142,147,159,159,147,165,156,149,164,137,166,135,142,133,136,127,143,165,121,142,148,158,146,154,157,124,125,158,159,164,143,154,152,141,164,131,152,152,161,143,143,139,131,125,145,140,163)

gender = c(1,2,1,2,1,1,1,2,1,1)
barplot(gender)
barplot(table(gender))
barplot(table(gender)/length(gender))

barplot(table(direction), col=c("red","green","blue"))
barplot(table(direction), col=c("red","green","blue"), main="Directions of food delivery")
barplot(table(direction), col=c("red","green","blue"), main="Directions of food delivery", legend.text=c("dir1","dir2","dir3"))
barplot(table(direction), col=c("red","green","blue"), main="Directions of food delivery", legend.text=c("dir1","dir2","dir3"), sub="Three directions")
barplot(table(direction), col=c("red","green","blue"), main="Directions of food delivery", legend.text=c("dir1","dir2","dir3"), sub="Three directions", xlab="Food Delivery Directions", ylab="Number of Deliveries")

hist(height)
hist(height, freq=FALSE)
hist(height, main="Heights of persons", col="green", xlab="Heights", ylab="Number of Persons")
hist(height, main="Heights of persons", col="red", xlab="Heights", ylab="Number of Persons", density=2)
hist(height, main="Heights of persons", col="red", xlab="Heights", ylab="Number of Persons", density=8)
hist(height, main="Heights of persons", col="red", xlab="Heights", ylab="Number of Persons", density=8, angle=100)
