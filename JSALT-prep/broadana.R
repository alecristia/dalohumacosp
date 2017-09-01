#
namj="/Users/acristia/Documents/nam-j/all/"
casj="/Users/acristia/Documents/CAS-J/Cas-J/"
stacl="/Users/acristia/Box\ Sync/aclew_starter/_5minutes/"
all=NULL
for (folder in c(namj,casj,stacl)){#
  dir(path=folder,pattern="txt")->txts
  txts=txts[grep("README",txts,invert=T)]
  txts=txts[grep("lena",txts,invert=T)]
  for(thisf in ??txts){#[1:3]
    nlines=length(count.fields(paste0(folder,thisf), sep="\n"))
    if(nlines>0) nam=rbind(nam,cbind(folder,thisf,read.table(paste0(folder,thisf))))
  }
}
names(all)<-c("corpus","file","on","off","id")
write.table(all,"../derivedFiles/joinedCoded20170801.txt",row.names=F,sep="\t",quote=T)

all$type=substr(all$id,1,2)

#get n of chi segments
table(all$id)[grep("CHI",names(table(all$id)))]
all$dur=all$off-all$on
all$chi=NA
all$chi[grep("CHI",all$id)]<-T
sum(all$dur[all$chi],na.rm=T)/3600

sum(all$dur[all$type %in% c("MA")],na.rm=T)/3600
sum(all$dur[all$type %in% c("FA")],na.rm=T)/3600
sum(all$dur[all$type %in% c("FC","MC","UC")],na.rm=T)/3600


