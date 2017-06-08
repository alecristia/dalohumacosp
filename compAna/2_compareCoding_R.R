#reliab_folder="C:\\Users\\scaff\\Documents\\en_cours\\Baqu-20171112_txt\\"
#reliab_folder="C:\\Baqu-20171112_txt\\"
reliab_folder="/Users/acristia/Documents/habilis_backup/PROJECTS/1-developing/WACK-all/reliability2/Baqu-20171112_txt/"
csvs=dir(path=reliab_folder,pattern="csv")
all=NULL
empty=NULL
for(thisf in csvs){
  read.csv(paste0(reliab_folder,thisf))->thiscsv
  bits=strsplit(thisf,"_")
  if(dim(thiscsv)[1]>0){
    all=rbind(all,cbind(bits[[1]][1],bits[[1]][4],bits[[1]][5],bits[[1]][6],thiscsv))
  }else{
    empty=rbind(empty,cbind(bits[[1]][1],bits[[1]][4],bits[[1]][5],bits[[1]][6]))
  }
}
names(all)[1:4]<-c("file","start","end","coder")

#minor clean
all$tier_broad=as.character(all$tier)
all$tier_broad=gsub(" ","",all$tier)
all$tier_broad[grep("parl",all$tier_broad)]<-"2parlou+"
all$tier_broad[grep("oi",all$tier_broad)]<-"Loi-fai-2e"
all$tier_broad[all$tier_broad %in% c("C1","C2")]<-"OCH"
all$tier_broad[all$tier_broad %in% c("FA1","FA2")]<-"FA"
all$tier_broad[all$tier_broad %in% c("MA1","MA2")]<-"MA"

all$age=NA
all$age[all$tier_broad %in% c("CHI","OCH")]<-"C"
all$age[all$tier_broad %in% c("FA","MA")]<-"A"

all$parole=NA
all$parole[all$tier_broad %in% c("OCH","FA","MA")]<-"otherSpeech"


all$coder<-gsub(".csv","",all$coder)
all$dur=all$tmax-all$tmin

#create sums per tier, coder, and chunk
sums=aggregate(all$dur,by=list(all$coder,all$start,all$tier_broad),sum)
names(sums)<-c("coder","start","tier","sumdur")
sums$uid=paste(sums$start,sums$tier)
sums_m1<-sums[sums$coder=="m1",]
sums.y<-sums[sums$coder=="m2",]
joint=merge(sums_m1,sums.y,by="uid")
names(joint)<-gsub(".x","_m1",names(joint))
names(joint)<-gsub(".y",".y",names(joint))


#create sums per parole, coder, and chunk
sums=aggregate(all$dur,by=list(all$coder,all$start,all$parole),sum)
names(sums)<-c("coder","start","tier","sumdur")
sums$uid=paste(sums$start,sums$tier)
sums_m1<-sums[sums$coder=="m1",]
sums.y<-sums[sums$coder=="m2",]
joint_p=merge(sums_m1,sums.y,by="uid")
names(joint_p)<-gsub(".x","_m1",names(joint_p))
names(joint_p)<-gsub(".y",".y",names(joint_p))

#create sums per parole, coder, and chunk
sums=aggregate(all$dur,by=list(all$coder,all$start,all$age),sum)
names(sums)<-c("coder","start","tier","sumdur")
sums$uid=paste(sums$start,sums$tier)
sums_m1<-sums[sums$coder=="m1",]
sums.y<-sums[sums$coder=="m2",]
joint_a=merge(sums_m1,sums.y,by="uid")
names(joint_a)<-gsub(".x","_m1",names(joint_a))
names(joint_a)<-gsub(".y",".y",names(joint_a))

pdf("C:\\Users\\scaff\\Documents\\comparison2.pdf")

plot(joint$sumdur_m1~joint$sumdur.y)
for(thislevel in levels(as.factor(joint$tier_m1))){
  plot(joint$sumdur_m1 [joint$tier_m1 == thislevel] ~joint$sumdur.y [joint$tier_m1 == thislevel], main=thislevel)
  if(length(joint$sumdur_m1 [joint$tier_m1 == thislevel]) > 3) text(mean(joint$sumdur.y [joint$tier_m1 == thislevel]),mean(joint$sumdur_m1 [joint$tier_m1 == thislevel]),round(cor.test(joint$sumdur.y [joint$tier_m1 == thislevel], joint$sumdur_m1 [joint$tier_m1 == thislevel])$estimate,3))
  
}



for(thislevel in levels(as.factor(joint_p$tier_m1))){
  plot(joint_p$sumdur_m1 [joint_p$tier_m1 == thislevel] ~joint_p$sumdur.y [joint_p$tier_m1 == thislevel], main=thislevel)
  if(length(joint_p$sumdur_m1 [joint_p$tier_m1 == thislevel]) > 3)   text(mean(joint_p$sumdur.y [joint_p$tier_m1 == thislevel]),mean(joint_p$sumdur_m1 [joint_p$tier_m1 == thislevel]),round(cor.test(joint_p$sumdur.y [joint_p$tier_m1 == thislevel], joint_p$sumdur_m1 [joint_p$tier_m1 == thislevel])$estimate,3))
}



for(thislevel in levels(as.factor(joint_a$tier_m1))){
  plot(joint_a$sumdur_m1 [joint_a$tier_m1 == thislevel] ~joint_a$sumdur.y [joint_a$tier_m1 == thislevel], main=thislevel)
  if(length(joint_a$sumdur_m1 [joint_a$tier_m1 == thislevel]) > 3)  text(mean(joint_a$sumdur.y [joint_a$tier_m1 == thislevel]),mean(joint_a$sumdur_m1 [joint_a$tier_m1 == thislevel]),round(cor.test(joint_a$sumdur.y [joint_a$tier_m1 == thislevel], joint_a$sumdur_m1 [joint_a$tier_m1 == thislevel])$estimate,3))
}

dev.off()
