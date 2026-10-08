for(i in 4:6){print(-4+3i+i^2)}
for(i in 5:7){print(i+3*i-2*i**2)}
y=1
while(y<16){
  print(c("Mooc Courses","are helpful"))
  y=y+2
  print(c("Mooc Courses","is not helpful"))
  y=y+3
}
x=2
while(x<25){x=x^2-20;if(x==35)break;print(x);}
z = function(x,y){
  sqrt(x^2+y^2) + log(x^4+y^4) - exp(x^-2-y^-2)
}

z(1,2)

sqrt(abs(seq(-10,10,by=5)))
seq(5,-2,by=-2)
-seq(to=-8,length=6)
seq(to=88,length=8,by=8)
seq(from=-6,length=6,by=-0.6)
X=c(25,77,35,140,8,20,120,56,19)
Y=seq(along=X)
Y
Y=c(25,77,35,140,8,20,120,56,19)
X=c(5,7,1,4,6,3,2,9,8)
Y[X[7]]

x=c(34,154,176,43,88,92,37,65,59,26,38,74,66)
x[(x-30>100)]

x = c(34,154,176,43,88,92,37,65,59,26,38,74,66)

x[(sqrt(x^2 - 10*x)) < 30]
y=15:5
y[(2:5)]
abs(seq(-1,3))


