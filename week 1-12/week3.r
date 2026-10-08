c(2,3,5,7) + c(-2,-3,-5,8)
c(2,3,5,7) - c(-2,-3,-5,8)
c(2,3,5,7) * c(-2,-3,-5,8)
c(2,3,5,7) / c(-2,-3,-5,8)

2^3
2**3
2^0.5
2**0.5
2^-0.5
c(2,3,5,7)^2
c(2,3,5,7)^c(2,3)
c(1,2,3,4,5,6)^c(2,3,4)

2 %/% 2
5 %/% 2
7 %/% 3
c(2,3,5,7) %/% 2
c(2,3,5,7) %/% c(2,3)

2 %% 2
3 %% 2
7 %% 3
7 %% 4
c(2,3,5,7) %% 2
c(2,3,5,7) %% c(2,3)

max(1.2,3.4,-7.8)
max(c(1.2,3.4,-7.8))
min(1.2,3.4,-7.8)
min(c(1.2,3.4,-7.8))
mean(2,3,4)
mean(c(2,3,4))
abs(-4)
abs(c(-1,-2,-3,4,5))
sqrt(4)
sqrt(c(4,9,16,25))
sum(c(2,3,5,7))
prod(c(2,3,5,7))
round(1.23)
round(1.83)
log(10)
log(exp(1))
log(c(10,100,1000))
log10(10)
log10(100)
log10(c(10,100,1000))

x1 = c(1,2,3,4)
x1
x2 = x1^2
x2

c(1,2,3,4) + sum(c(1,2,3,4))*prod(c(1,2))
abs(c(1,2,3,4)-sum(c(1,2,3,4))*prod(c(1,2)))

x = matrix(nrow=4,ncol=2,data=c(1,2,3,4,5,6,7,8))
x
x[3,2]

x = matrix(nrow=4,ncol=2,data=c(1,2,3,4,5,6,7,8),byrow=FALSE)
x

y = matrix(nrow=4,ncol=2,data=c(1,2,3,4,5,6,7,8),byrow=TRUE)
y

dim(x)
nrow(x)
ncol(x)
mode(x)
attributes(x)

help("matrix")
as.matrix(1:10)
is.matrix(as.matrix(1:10))
data(warpbreaks)
is.matrix(warpbreaks)
as.matrix(warpbreaks[1:10,])
