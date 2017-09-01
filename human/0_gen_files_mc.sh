
for j in */; do

#generate filename
    k=`echo $j | tr -d "/"`
    line=`grep $k tsiRec2017.csv`
    chi_id=`echo $line | cut -d"," -f1`
    day=`echo $line | cut -d"," -f2`
    d=`echo $day | cut -d'/' -f1`
    m=`echo $day | cut -d'/' -f2`
    y=`echo $day | cut -d'/' -f3`
    if [ ${#y} -eq 2 ] ; then y="20$y"; fi
    if [ ${#m} -eq 1 ] ; then m="0$m"; fi
    if [ ${#d} -eq 1 ] ; then d="0$d"; fi
    day_iso=$y$m$d

    filename="${chi_id}_${day_iso}"

#make a set of txt's containing the list of files inside each folder 
    for files in $j*; do
	echo "file '$files'" >> $filename.txt
    done
done

for j in *.txt; do
     k=`echo $j | sed "s/txt/wav/"`
     ffmpeg -f concat -safe 0 -i $j -ac 1 -acodec pcm_s16le $k
done
