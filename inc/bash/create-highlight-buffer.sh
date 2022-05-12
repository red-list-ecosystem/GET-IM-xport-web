#! /bin/bash

LSTMAP=$1
INPUTDIR=$2
OUTPUTDIR=$3

while IFS="|" read code mcode mver mtype status
do
   INPUTMAP=${mcode}_${mver}.tif
   OUTPUTMAP=${mcode}_${mver}.json

   if [ -e ${OUTPUTDIR}/${OUTPUTMAP} ]
   then
      echo "Map for ${code} (${mcode} ${mver}) already exists"
   else
   if [ -e ${INPUTDIR}/${INPUTMAP} ]
      then
         echo "create a highlight buffer around map for ${code} (${mcode} ${mver}) "

         r.in.gdal --overwrite input=$INPUTDIR/$INPUTMAP output=indicativemap
         r.buffer --overwrite input=indicativemap output=buffermap distances=300000
         r.mapcalc --overwrite expression="tmp000=if(buffermap,1,null())"
         r.to.vect --overwrite -t input=tmp000 output=vbuffer type=area

         v.out.ogr --overwrite -c type=area format=GeoJSON input=vbuffer output=$OUTPUTDIR/$OUTPUTMAP

      else
         echo "GeoTIFF map for ${code} (${mcode} ${mver}) is missing"
      fi
   fi
done < $LSTMAP
