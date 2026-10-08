x=list("India","1947")
append(x,10)
x=list("USA","1776")
append(x,30,after=1)
x=list("India","Nepal","China","Bhutan",19,47,"19+47")
x[2:3]
z=list(z1=seq(2,5),z2="Sequence")
names(z)[2]="y2"
z
factor(c(4,5,9,4,6,6,7,7,9))
data=c(4,5,9,4,6,6,7,7,9)
factor(data)
levels(data)=c('A','B','C','D')
data
data=factor(c(11,22,22,58,11,22,11,58,63,63),levels=c(11,22,58,63),ordered=TRUE)
data
factor(c(rep("tail",2),rep("head",3)))
unclass(factor(c("Apple","Banana","Orange","Banana","Apple","Orange","Apple","Orange"),levels=c("Apple","Banana","Orange")))
as.factor(c(15,22,12,13,14,15,14,12,13,12,15))
print(22/7,digits=5)
print("Total no. of states and UTs in India is",(28+8),"28 states and 8UTs",digits=4)
print("There are");print(28+8);print("states and UTs in India")
format(3141593,big.mark="+")
print(format(3.14,digits=6,nsmall=7))