###################################
#This code was made by Alex Cristia (main algorithmes) and Ben Touati (somes algorithmes and cleaning), Laboratoire des sciences cognitives et psycholinguistiques
#Département de sceicnes cognitives, ENS, CNRS

# It compares vad made by two different coders on a list of record 

#It takes in input a list of csv indicating detected speech of a list of records (each record is associated with two csv, each of them made by a diffrent coder) and it makes in output a plot that compares
# detected speech of different coders for each record

#Note that the input must be named as A_B_C_D_E.csv knowing that 
#A=Name of the folder (this must be the same for each csv 
#B=Id of the record (you can put everithing you want) 
#C= start time of the record and D=End time of the record (because our date is composed by sample of 24h records, we need this information) but you can put everithing you want
#E=NameOfCoder
#For each csv on a single record, the name of the csv must be exactly the same except the name of the coder
#for instance:
#PloomPLoom_txt1_1800_2100_m1.csv      PloomPLoom_txt1_1800_2100_m2.csv
#PloomPLoom_txt2_2700_3000_m1.csv      PloomPLoom_txt2_2700_3000_m2.csv
#PloomPLoom_txt3_5800_6100_m1.csv      PloomPLoom_txt3_5800_6100_m2.csv

#################################

plot_results <-function(to_compare){
  for(thislevel in levels(as.factor(to_compare$tier_m1))){
    plot(to_compare$sumdur_m1 [to_compare$tier_m1 == thislevel] ~to_compare$sumdur.y [to_compare$tier_m1 == thislevel], main=thislevel, xlab=paste0('Speech time detected by ',x_axis,' (in seconds)'), ylab=paste0('Speech time detected by ',y_axis,' (in seconds)'))
    if(length(to_compare$sumdur_m1 [to_compare$tier_m1 == thislevel]) > 3){
      text(mean(to_compare$sumdur.y [to_compare$tier_m1 == thislevel]),mean(to_compare$sumdur_m1 [to_compare$tier_m1 == thislevel]),round(cor.test(to_compare$sumdur.y [to_compare$tier_m1 == thislevel], to_compare$sumdur_m1 [to_compare$tier_m1 == thislevel])$estimate,3))
    }
  }
}

##delete lines where text=0 | x (the hand made segmentation present some lines where the speech is marked as x or 0 saying that this is not a real speech)
delete_non_speech<-function(){
  row=1
  while(row<=length(thiscsv[,3])){
    if(thiscsv[row,3]==0|thiscsv[row,3]=="x"){
      thiscsv<-thiscsv[-row,]
      row=row-1                 #if I don't put this line, when a 0 is following another 0, the second one is not deteled (don't know why)
    }
    row=row+1
    print(row)
  }
  return(thiscsv)
}

##create a table called "all" that takes in count all the cvs we want to compare
create_all<-function(){
  bits=strsplit(thisf,"_")
  if(dim(thiscsv)[1]>0){
    all=rbind(all,cbind(bits[[1]][1],bits[[1]][4],bits[[1]][5],bits[[1]][6],thiscsv))
  }else{
    empty=rbind(empty,cbind(bits[[1]][1],bits[[1]][4],bits[[1]][5],bits[[1]][6]))
  }
  return(all)
}

##function that delete the overlappingg
DeleteOverlap <-function(all_column) {
  i=2
  while (i < length(all$tier)-1){
    if (all$tmax[i]> (all$tmin[i]+60)){
      all$tmax[i]=all$tmin[i]+60
    }
    if((all$tmin[i+1]<all$tmax[i]) & (all$coder[i]==all$coder[i+1]) & (all$start[i]==all$start[i+1]))
    {
      if (all_column[i]!='NA'){
        all$tmin[i+1]=all$tmax[i]
      }
      else     {
        all$tmax[i]=all$tmin[i+1]
      }
    }
    if(all$tmin[i]>all$tmax[i]){
      all$tmax[i]=all$tmin[i]
    }
    i=i+1
  }
  return(all)
}

one_min_max <-function(sumdurAxis){
  i=1
  while (i <= length(sumdurAxis)) {
    if (sumdurAxis[i]>60){
      sumdurAxis[i]=60
    }
    i=i+1
  }
return(sumdurAxis)
}


#create sums per parole, coder, and chunk
DurByTier<- function(all_column){
  ##create sum per tiers
  all<-DeleteOverlap(all_column)
  all_column[all_column %in% c("NA")]<-NA
  
  sums=aggregate(all$dur,by=list(all$coder,all$start,all_column),sum)
 # print(c("sums",sums))
  names(sums)<-c("coder","start","tier","sumdur")
  sums$uid=paste(sums$start,sums$tier)
  sums_m1<-sums[sums$coder==y_axis,]
  sums_m1$sumdur<-one_min_max(sums_m1$sumdur)
 
  sums.y<-sums[sums$coder==x_axis,]
  sums.y$sumdur<-one_min_max(sums.y$sumdur)
 
  joint_x=NULL
  joint_x=merge(sums_m1,sums.y,by="uid")
  names(joint_x)<-gsub(".x","_m1",names(joint_x))
  names(joint_x)<-gsub(".y",".y",names(joint_x))
  return(joint_x)
}
###################################################################
##main function
# in y_axis and x_axis, please put the name of the coders you want to compare (for the right format please see the top of this script)
setwd("/home/lscpuser/B.Touati/Baqu-20171112_txt/")
x_axis="m2"
y_axis="XVAD"
csvs=c(list.files(pattern=paste0(y_axis,".csv")),list.files(pattern=paste0(x_axis,".csv"))) #csvs: all the .csv of a folder that one wants to compare

all=NULL
empty=NULL
for(thisf in csvs){
  read.csv(thisf)->thiscsv
  thiscsv<-delete_non_speech()  
  all<-create_all()
}
names(all)[1:4]<-c("file","start","end","coder")

print(all[60:75,])

#delete objects that are not useful anymore
rm(thiscsv, thisf)


#minor clean
all$tier_broad=as.character(all$tier)                           #transform tiers into strings
all$tier_broad=gsub(" ","",all$tier)                            #suppress spaces
all$tier_broad[grep("parl",all$tier_broad)]<-"2parlou+"         #find all the tiers containing "parl" in their label and call them parlou+
all$tier_broad[grep("oi",all$tier_broad)]<-"Loi-fai-2e"         #find all the tiers containing "oi" in their label and call them loi-fai-2e
all$tier_broad[all$tier_broad %in% c("C1","C2")]<-"OCH"         #merge C1 and C2 tiers into 0CH
all$tier_broad[all$tier_broad %in% c("FA1","FA2")]<-"FA"        
all$tier_broad[all$tier_broad %in% c("MA1","MA2")]<-"MA"

#create new columns in the all table telling if the line contains what it's asked or not
all$age="NA"
all$age[all$tier_broad %in% c("CHI","OCH")]<-"C"
all$age[all$tier_broad %in% c("FA","MA")]<-"A"

all$age_tot="NA"
all$age_tot[all$tier_broad %in% c("FA","MA","CHI","OCH","Speech")]<-"C+A"

all$other_speech="NA"
all$other_speech[all$tier_broad %in% c("OCH","FA","MA","Speech")]<-"otherSpeech"

all$adult="NA"
all$adult[all$tier_broad %in% c("FA","MA","Speech")]<-"FA+MA"  #tentative en enlmevant les oparlent aux loins et els chevauchement de parole (à régler pour trouver le meilleurs indice de correlation

all$speech="NA"
all$speech[all$tier_broad %in% c("OCH","FA","MA","CHI","Speech","2parlou+","Loi-fai-2e")]<-"allSpeeches"  #tentative en enlmevant les oparlent aux loins et els chevauchement de parole (à régler pour trouver le meilleurs indice de correlation

all$child="NA"
all$child[all$tier_broad %in% c("CHI","Speech")]<-"child"  #compare speech-child

all$coder<-gsub(".csv","",all$coder)
all$dur=all$tmax-all$tmin

pdf("comparison5.pdf")
joint=NULL
#create sums per tier, coder, and chunk and plot each of them in a pdf
#joint_tier<-DurByTier(all$tier_broad)  (this works only if all axes are based on hand analysis )
joint$adult<-DurByTier(all$adult)
joint$speech<- DurByTier(all$speech)
joint$child<-DurByTier(all$child)
joint$age_tot<- DurByTier(all$age_tot)

for (column in joint){
  plot_results(column)
}

dev.off()
