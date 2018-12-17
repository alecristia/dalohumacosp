threshold=3

read.table("../derivedFiles/line_per_segment_age.txt",header=T)->x
summary(x)

#we'll get mixed up if the "noise" segments are in there --> violently removed
dim(x)
x[x$speakerID!="Noise" & !is.na(x$speakerID) & !is.na(x$beg) ,]->x
dim(x)
x$cb=NA
count=1
x$cb[1]=paste("cb",count,sep="")
for(thisline in 2:dim(x)[1]){
 #if there is a change in file, reset the conversation count
  if(x$File[thisline] != x$File[thisline-1]) count=1
  #if there is a silence greater than threshold, add one to conversation count
  if(x$beg[thisline] > (x$end[thisline-1] + threshold) ) count=count+1
  x$cb[thisline]=paste("cb",count,sep="")
}

summary(x)

x$cbu=factor(paste(x$File,x$cb,sep="_"))

write.table(cbind("on","off","cb","ts"),"../derivedFiles/z_toextract.txt",
            row.names=F,col.names=F,quote=F,append=F)
x$cb_type=NA
x$cb_on=NA
x$cb_off=NA
for(thiscb in levels(x$cbu)) {
  thist=as.character(levels(as.factor(as.character(x$speakerID_broad[x$cbu==thiscb]))))
  myt=thist[1]
  if(myt != "NA" & length(thist)>1) for(i in 2:length(thist)) myt=paste(myt,thist[i])
  x$cb_type[x$cbu==thiscb]<-myt
  x$cb_on[x$cbu==thiscb]<-min(x$beg[x$cbu==thiscb])
  x$cb_off[x$cbu==thiscb]<-max(x$end[x$cbu==thiscb])
  write.table(cbind(min(x$beg[x$cbu==thiscb]),max(x$end[x$cbu==thiscb]),thiscb,myt),"../derivedFiles/z_toextract.txt",
              row.names=F,col.names=F,quote=T,append=T)
} 

