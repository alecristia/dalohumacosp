# -*- coding: utf-8 -*-
from lxml import etree
size= 0
StartEnd= list()
StartEnd=["_1800_2100_","_5400_5700_","_9000_9300_","_12600_12900_","_16200_16500_","_19800_20100_","_23400_23700_","_27000_27300_","_30600_30900_","_34200_34500_","_37800_38100_","_41400_41700_","_45000_45300_","_48600_48900_","_52200_52500_","_55800_56100_","_59400_59700_"]
currentfile=0
#création d'une boucle qui prend en compte tous les fihciers produits par elan (ici 15 mais à changer en fonction du nombre
for size in range(17):
        size+=1
        if size <=9:
                size=str(size)
                size='0'+size
        else: size=str(size)
        doc = etree.parse('/home/lscpuser/B.Touati/Baqu-20171112_txt/Speech_NonSpeech'+size+'_VAD0.03.xml')
        #pour la ligne précédente, mettre l'adresse des fichiers xml d'Elan
        root= doc.getroot()
        x=0
        y=0
        z=0
        SpeechAttrib=list()
        for child in root:
                if root[x][0].text=='Speech':
                	SpeechAttrib.append(child.attrib)
                	z+=1
                x+=1
        # ↑ permet d'afficher dans la liste speechattrib l'ensembe des lignes avec speech du fichier xml
        speech= list()
        while y < z:
                speech.append([SpeechAttrib[y].get('start'),'Speech','1', SpeechAttrib[y].get('end')])
                y+=1
        # ↑ creer liste dans le bon ordre à partir du xml
        SpeechTime=[]
        x=0
        for x in range(len(speech)):
            tmin=float(speech[x][0])
            tmax=float(speech[x][3])
            if tmax>180 and tmin<240:
                if tmin<180:
                    speech[x][0]='180.0'
                if tmax>240:
                    speech[x][3]='240.0'
                SpeechTime.append(speech[x])
        #↑ Enlever de la liste les lignes qui ne correspondent pas aux segments analysée par un humain etpour els segment VAD qui sotn a cheval sur le traité et le non traité, faire une découpe a partir du temps traité
        x=0
        chn='tmin, tier, text, tmax'
        for x in range(len(SpeechTime)):
            chn+="\n"+", ".join(SpeechTime[x])
            x+=1
        f= open('Baqu-20171112_txt_'+size+StartEnd[currentfile]+'VAD0.03.csv', 'w')
        f.write(chn)
        f.close()
        currentfile+=1
        print(size)
        # ↑ enregistre dans un fichier csv

        
