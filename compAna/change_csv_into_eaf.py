# -*- coding: utf-8 -*-
class Temps:

    def __init__(self, number, time):
        self.number = number
        self.time = time
        

    def __repr__(self):
       return "{} {}".format(
           self.number, self.time)


class LigneInventaire:

    def __init__(self, tmin, tier, speech, tmax):
        self.tmin = tmin
        self.tier = tier
        self.speech= speech
        self.tmax = tmax

    def __repr__(self):
       return "{}, {}, {}, {}".format(
           self.tmin, self.tier, self.speech, self.tmax)

def define_ajout(key, i):
	ajout=[]
	while lignes[i]!=key:
		ajout.append(lignes[i])
		i+=1
	ajout=''.join(ajout)
	return(ajout)
#read Input

Input='Baqu-20171112_txt_01_1800_2100_XVAD.csv'
Input_wav=Input[:-9]+".wav"
Output=Input[:-5]+".eaf"

x=open(Input, 'r')
Doc_lines=x.readlines()
x.close()
del(Doc_lines[0])

#create inventaire of ligne
inventaire=[]
for lignes in Doc_lines:
	i=0
	tmin=define_ajout(',', i)
	tmin=int(float(tmin)*1000)
	print(tmin)
	i+=len(str(tmin))+1
	tier=define_ajout(',', i+1)
	i+=len(tier)+2
	speech=define_ajout(',', i+1)
	i+=len(speech)+2
	tmax=define_ajout('\n', i)
	tmax=int(float(tmax)*1000)
	inventaire.append(LigneInventaire(tmin, tier, speech, tmax))
del(inventaire[0])

#create liste of temps

temps=[]
for i in inventaire:
    temps.append(Temps('XXX', i.tmin))
    temps.append(Temps('XXX', i.tmax))
from operator import attrgetter
temps=sorted(temps, key=attrgetter('time'))
a=1
for i in temps:
    i.number=a
    a=a+1

#change time in iventaire by corresponding number
for time in temps:
    for ligne in inventaire:
        if time.time== ligne.tmin:
            ligne.tmin=time.number
        elif time.time== ligne.tmax:
            ligne.tmax=time.number

intro='<?xml version="1.0" encoding="UTF-8"?>\n<ANNOTATION_DOCUMENT AUTHOR="" DATE="'
import datetime
now=datetime.datetime.now()
now=str(now)
now=now[:10]+'T'+now[11:19]

intro+=now

#connaître le décalage horaire par rapprot à UTC
import time
dif_hour=divmod(time.altzone, 3600)[0]
dif_min=divmod(time.altzone, 3600)[1]

#formater comme il se doit
dif_min=str(divmod(dif_min,60)[0]).zfill(2)
if dif_hour<=0:
	dif_hour=str(0-dif_hour).zfill(2)
	dif_hour='+'+ dif_hour
else:
	dif_hour=str(0-dif_hour).zfill(3)
localtime=dif_hour+':'+dif_min

intro+=(localtime
+'" FORMAT="3.0" VERSION="3.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.mpi.nl/tools/elan/EAFv3.0.xsd">')

#Create TIME_ORDER string
time_order=''
space='    '
time_order+='\n'+space+'<TIME_ORDER>'
for i in temps:
    time_order+='\n'+space*2+'<TIME_SLOT TIME_SLOT_ID="ts'+str(i.number)+'" TIME_VALUE="'+str(i.time)+'"/>'
time_order+='\n'+space+'</TIME_ORDER>'


#Create TIER string
participants=[]
participants.append(inventaire[0].tier)
i=1
while i<len(inventaire):
    pareil=False
    for j in participants:
        if j==inventaire[i].tier:
            pareil=True
    if pareil==False:
        participants.append(inventaire[i].tier)
    i+=1

tier_str=''
body=''
ref=len(inventaire)+1

for participant in participants:
        tier_str+='\n'+space+'<TIER LINGUISTIC_TYPE_REF="transcription" PARTICIPANT="'+str(participant)+'" TIER_ID="'+str(participant)+'">'
        annot_ref=0
        while annot_ref<len(inventaire):
            if inventaire[annot_ref].tier==participant:
                tier_str+=('\n'+space*2+'<ANNOTATION>\n'
                +space*3+'<ALIGNABLE_ANNOTATION ANNOTATION_ID="a'+str(annot_ref+1)+'" TIME_SLOT_REF1="ts'+str(inventaire[annot_ref].tmin)+'" TIME_SLOT_REF2="ts'+str(inventaire[annot_ref].tmax)+'">\n'
                +space*4+'<ANNOTATION_VALUE></ANNOTATION_VALUE>\n'
                +space*3+'</ALIGNABLE_ANNOTATION>\n'
                +space*2+'</ANNOTATION>')
                if participant=='CHI'and inventaire[annot_ref].speech=='1':
                   body+="""
        <ANNOTATION>
            <REF_ANNOTATION ANNOTATION_ID="a{}" ANNOTATION_REF="a{}" CVE_REF="cveid3">
                <ANNOTATION_VALUE>C</ANNOTATION_VALUE>
            </REF_ANNOTATION>
        </ANNOTATION>""".format(ref, annot_ref)
                elif participant=='CHI'and inventaire[annot_ref].speech!='1':
                    body+="""
        <ANNOTATION>
            <REF_ANNOTATION ANNOTATION_ID="a{}" ANNOTATION_REF="a{}" CVE_REF="cveid3">
                <ANNOTATION_VALUE></ANNOTATION_VALUE>
            </REF_ANNOTATION>
        </ANNOTATION>""".format(ref, annot_ref)
                ref+=1
            annot_ref+=1
        tier_str+='\n'+space+'</TIER>'

        if participant=='CHI':
            
                annot_ref=len(inventaire)+1
                tier_str+='\n'+space+'<TIER LINGUISTIC_TYPE_REF="VCM" PARENT_REF="CHI" PARTICIPANT="CHI" TIER_ID="vcm@CHI">'+body
                tier_str+=('\n'
                        +space+'</TIER>\n'
                        +space+'<TIER LINGUISTIC_TYPE_REF="LEX" PARENT_REF="vcm@CHI" PARTICIPANT="CHI" TIER_ID="lex@CHI"/>\n'
                        +space+'<TIER LINGUISTIC_TYPE_REF="MWU" PARENT_REF="lex@CHI" PARTICIPANT="CHI" TIER_ID="mwu@CHI"/>\n')
        else:
                tier_str+="""
    <TIER LINGUISTIC_TYPE_REF="XDS" PARENT_REF="{}" PARTICIPANT="{}" TIER_ID="xds@{}"/>""".format(participant, participant, participant)


#Create OUTRO

outro="""
    <LINGUISTIC_TYPE CONSTRAINTS="Symbolic_Association" CONTROLLED_VOCABULARY_REF="xds" GRAPHIC_REFERENCES="false" LINGUISTIC_TYPE_ID="XDS" TIME_ALIGNABLE="false"/>
    <LINGUISTIC_TYPE CONSTRAINTS="Symbolic_Association" CONTROLLED_VOCABULARY_REF="vcm" GRAPHIC_REFERENCES="false" LINGUISTIC_TYPE_ID="VCM" TIME_ALIGNABLE="false"/>
    <LINGUISTIC_TYPE CONSTRAINTS="Symbolic_Association" CONTROLLED_VOCABULARY_REF="mwu" GRAPHIC_REFERENCES="false" LINGUISTIC_TYPE_ID="MWU" TIME_ALIGNABLE="false"/>
    <LINGUISTIC_TYPE CONSTRAINTS="Symbolic_Association" CONTROLLED_VOCABULARY_REF="lex" GRAPHIC_REFERENCES="false" LINGUISTIC_TYPE_ID="LEX" TIME_ALIGNABLE="false"/>
    <LINGUISTIC_TYPE GRAPHIC_REFERENCES="false" LINGUISTIC_TYPE_ID="transcription" TIME_ALIGNABLE="true"/>
    <LANGUAGE LANG_DEF="http://cdb.iso.org/lg/CDB-00130975-001" LANG_ID="und" LANG_LABEL="undetermined (und)"/>
    <CONSTRAINT DESCRIPTION="Time subdivision of parent annotation's time interval, no time gaps allowed within this interval" STEREOTYPE="Time_Subdivision"/>
    <CONSTRAINT DESCRIPTION="Symbolic subdivision of a parent annotation. Annotations refering to the same parent are ordered" STEREOTYPE="Symbolic_Subdivision"/>
    <CONSTRAINT DESCRIPTION="1-1 association with a parent annotation" STEREOTYPE="Symbolic_Association"/>
    <CONSTRAINT DESCRIPTION="Time alignable annotations within the parent annotation's time interval, gaps are allowed" STEREOTYPE="Included_In"/>
    <CONTROLLED_VOCABULARY CV_ID="mwu"
        <DESCRIPTION LANG_REF="und"/>
    </CONTROLLED_VOCABULARY>
    <CONTROLLED_VOCABULARY CV_ID="lex"
        <DESCRIPTION LANG_REF="und"/>
    </CONTROLLED_VOCABULARY>
    <CONTROLLED_VOCABULARY CV_ID="xds"
        <DESCRIPTION LANG_REF="und"/>
    </CONTROLLED_VOCABULARY>
    <CONTROLLED_VOCABULARY CV_ID="vcm"
        <DESCRIPTION LANG_REF="und"/>
    </CONTROLLED_VOCABULARY>
    <EXTERNAL_REF EXT_REF_ID="er1" TYPE="ecv" VALUE="https://raw.githubusercontent.com/marisacasillas/DARCLE-AnnSchDev/master/ACLEW/External-closed-vocabularies/ACLEW-basic-vocabularies.ecv"/>
</ANNOTATION_DOCUMENT>"""


header="""
    <HEADER MEDIA_FILE="" TIME_UNITS="milliseconds">
        <MEDIA_DESCRIPTOR MEDIA_URL="file:file" MIME_TYPE="audio/x-wav" RELATIVE_MEDIA_URL="./{}"/> 
        <PROPERTY NAME="lastUsedAnnotationId">{}</PROPERTY>
    </HEADER>""".format(Input_wav, annot_ref-1)

outside=str(intro)+str(header)+str(time_order)+str(tier_str)+str(outro)
f= open(Output, 'w')
f.write(outside)
f.close()



