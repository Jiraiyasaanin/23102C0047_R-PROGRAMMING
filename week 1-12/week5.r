x = NA
is.na(x)

x = c(11,NA,13,NA)
is.na(x)

mean(x)
mean(x,na.rm=TRUE)

which(is.na(x))
sum(is.na(x))
complete.cases(x)

y = na.omit(x)
y
mean(y)

x = 5
if(x > 4) x * 3

x = 3
if(x > 4) x * 3

x = 5
if(x > 4){x * 3}

x = 3
if(x > 4){x * 3}

x = 6
if(x > 3){
print("The value is more than 3")
}

x = 2
if(x > 3){
print("The value is more than 3")
}

x = 5
if(x == 3){
x = x-1
}else{
x = 2*x
}
x

x = 3
if(x == 3){
x = x-1
}else{
x = 2*x
}
x

x = 6
if(x > 3){
print("The value is more than 3")
}else{
print("The value is less than 3")
}

x = 2
if(x > 3){
print("The value is more than 3")
}else{
print("The value is less than 3")
}

x = 5
if(x == 3){
x = x-1
}else if(x < 3){
x = x+5
}else{
x = 2*x
}
x

x = 2
if(x == 3){
x = x-1
}else if(x < 3){
x = x+5
}else{
x = 2*x
}
x

x = 3
if(x == 3){
x = x-1
}else if(x < 3){
x = x+5
}else{
x = 2*x
}
x

x = 1:10
x
ifelse(x < 6,x^2,x+1)

x = c(7,9,8,4)
ifelse(x %% 2 == 0,"even number","odd number")

switch(2,"apple","banana","orange")
switch(1,"apple","banana","orange")
switch("colour","colour"="blue","gender"="male","volume"=50)
switch("volume","colour"="blue","gender"="male","volume"=50)
switch(4,"apple","banana","orange")
switch("size","colour"="blue","gender"="male","volume"=50)

x = c(10,15,8,14,6,12)
x
which(x == 14)
which(x != 12)
which(x > 10)

x = matrix(nrow=3,ncol=3,data=1:9)
x
which.min(x)
which.max(x)
which(x %% 2 == 1)
which(x %% 2 == 1,arr.ind=TRUE)
