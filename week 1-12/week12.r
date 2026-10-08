cust = matrix(nrow=4, ncol=3, data=c(2,20,30,26,53,40,42,15,25,30,75,100), byrow=TRUE)
cust
barplot(cust)
barplot(cust, names.arg=c("Shop 1","Shop 2","Shop 3"), xlab="Shops", ylab="Days", col=c("red","green","orange","brown"))

gender = c(1,2,1,2,1,1,1,2,1,1)
gender
pie(gender)
pie(table(gender))

direction = c(1,1,2,1,2,3,2,2,3,3,3,1,2,3,2,2,3,1,1,3,3,1,2,1,3,3,3,2,2,2,2,1,2,2,1,1,1,3,2,2,1,2,3,2,2,1,2,3,3,2,1,2,2,3,1,1,2,1,2,3,2,3,2,2,3,1,2,3,3,3,2,1,1,1,2,1,1,2,1,2,3,3,1,2,3,3,2,1,2,3,2,1,3,2,2,2,2,3,2,2)
pie(table(direction))
pie(table(direction), col=c("red","green","blue"), main="Directions of food delivery")

par(mfrow=c(1,2))
barplot(table(direction))
pie(table(direction))

par(mfrow=c(2,1))
barplot(table(direction))
pie(table(direction))

height = c(166,125,130,142,147,159,159,147,165,156,149,164,137,166,135,142,133,136,127,143,165,121,142,148,158,146,154,157,124,125,158,159,164,143,154,152,141,164,131,152,152,161,143,143,139,131,125,145,140,163)
hist(height)
hist(height, freq=FALSE)
hist(height, main="Heights of persons", col="green", xlab="Heights", ylab="Number of Persons")
hist(height, main="Heights of persons", col="red", xlab="Heights", ylab="Number of Persons", density=2)
hist(height, main="Heights of persons", col="red", xlab="Heights", ylab="Number of Persons", density=8)
hist(height, main="Heights of persons", col="red", xlab="Heights", ylab="Number of Persons", density=8, angle=100)

hours = c(2,3,4,5,6,7,8,9,10,11)
marks = c(35,40,45,50,55,60,65,70,75,80)
plot(hours, marks)
plot(hours, marks, type="l")
plot(hours, marks, type="b")
plot(hours, marks, type="o")
plot(hours, marks, type="h")
plot(hours, marks, type="s")
plot(hours, marks, xlab="Number of weekly study hours", ylab="Marks", main="Study Hours and Marks")

scatter.smooth(hours, marks)
scatter.smooth(hours, marks, lpars=list(col="red"))

x = seq(-10,10,length=30)
y = x
f = function(x,y){r=sqrt(x^2+y^2); 10*sin(r)/r}
z = outer(x,y,f)
z[is.na(z)] = 1
persp(x,y,z,theta=30,phi=30,expand=0.5,col="lightblue")
persp(x,y,z,theta=30,phi=30,expand=0.5,col="lightblue",ltheta=120,shade=0.75,ticktype="detailed",xlab="X",ylab="Y",zlab="Sinc(r)")

x = c(10,20,30)
y = c(1,2,3)

example1 = function(x,y)
{
n = length(x)
x1 = 0
y1 = 0
z1 = 0
for(i in 1:n)
{
x1[i] = x[i]^2
y1[i] = y[i]^2
z1[i] = (x[i]/y[i])^2
}
sum_square_x = sum(x1)
sum_square_y = sum(y1)
sum_square_z = sum(z1)
g = sum_square_x/sum_square_y
h = sum_square_z
cat("The value of g and h are",g,"and",h,"respectively","\n")
}

example1(x,y)

x = c(67,87,26,85,6,45)
y = c(54,64,22,94,20,88)
example1(x,y)

g = function(x,y)
{
(x+log(y))/y
}

f = function(x,y)
{
(((g(x,y))^2)/(5+(g(x,y))^3))*(exp(g(x,y)))^(2/3)
}

x = 10
y = 20
f(x,y)

x = 1896
y = 23454
f(x,y)

f = function(x)
{
if(x>0){exp((x+log(1+x^3))/x^2)}
else if(x==0){10}
else{(2+x^3)/x}
}

h = function()
{
x = seq(-1,5,by=0.2)
y = 0
for(i in 1:length(x))
{
y[i] = f(x[i])
}
plot(x,y,type="l")
}

f(123)
f(-123)
f(0)
f(8)
f(-4)
f(0)
h()
