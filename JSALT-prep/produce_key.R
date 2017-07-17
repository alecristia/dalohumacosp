folder="_1minute/"
files=dir(folder,pattern="csv")

all=NULL
for(thisf in files){
  dat=read.csv(paste0(folder,thisf))
  if(dim(dat)[1] != 0) all=rbind(all,cbind(thisf,dat)) 
}

#"File"	"beg"	"end"	"speakerID"	"type"
#"aia_20160714_45180"	0.04	0.61	"CHI"	0
#First letter= sex (F=female, M=male, U=unspecified which only occurs for children)
#Second letter= age (A=adult, C=child)

all=all[,c("thisf","tmin","tmax","tier","text")]
names(all)<-c("File",	"beg",	"end",	"speakerID",	"type")

all$speakerID=gsub("*","",all$speakerID,fixed=T)
all$speakerID=gsub(" ","",all$speakerID,fixed=T)
table(all$speakerID)
all$speakerID[all$speakerID == "Autre"]<-"Noise"
all$speakerID[all$speakerID == "FA2"]<-"FA3"
all$speakerID[all$speakerID == "FA1"]<-"FA2"
all$speakerID[all$speakerID == "MOT"]<-"FA1"
all$speakerID[all$speakerID %in% c("+2parl","2POPMT","2parlou+")]<-"XOL"
all$speakerID[all$speakerID %in% c("LF2P","Loin","Loin-faible")]<-"SP"
all$speakerID=gsub("^C","UC",all$speakerID,perl=T)
all$speakerID[all$speakerID %in% c("UCHI")]<-"CHI"
table(all$speakerID)

all$type[all$type %in% c(" ","\177")]<-NA
all$type[all$type %in% c("1&","11")]<-"1"
table(all$type)

write.table(all,"_1minute_key/vad_speakerID_cat.txt", row.names=F,quote=T,sep="\t")
