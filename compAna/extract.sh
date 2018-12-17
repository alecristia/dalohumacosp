#!/bin/bash

# Script used to extract clips corresponding to conversational block

input="va_z_toextract.txt"
while IFS= read -r var
do
  line=`echo "$var" | tr -d "\""`
  type=`echo "$line" | cut -d " " -f 3 | cut -c1`
  if [ $type == "v" ] ; then
    on=`echo "$line" | cut -d " " -f 1`
    off=`echo "$line" | cut -d " " -f 2`
    cb=`echo "$line" | cut -d " " -f 3 | sed "s/ .*//"`
    file=`echo "$cb" | sed "s/_m1.*//"`
    folder=`echo "$file" | sed "s/\(_[12]\)\(_.*\)/\1/" `
    dur=`echo "$off $on" | awk '{print $1-$2}'`
    echo ffmpeg -ss $on -t $dur -i ${folder}/${file}.wav ${cb}.wav
  fi
done < "$input"
