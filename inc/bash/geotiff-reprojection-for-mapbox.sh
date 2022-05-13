#! /bin/bash
LSTMAP=$1
INPUTDIR=$2
OUTPUTDIR=$3

while IFS="|" read code mcode mver mtype status
do
   if [ -e ${OUTPUTDIR}/${mcode}_${mver}.tif ]
   then
      echo "Map for ${code} (${mcode} ${mver}) already exists"
   else
      if [ -e ${INPUTDIR}/${mcode}_${mver}.tif ]
      then
         echo "reproject map for ${code} (${mcode} ${mver}) to pseudomercator"
         gdalwarp -t_srs EPSG:3857 -r near -co COMPRESS=LZW -tr 2600 2600 -r mode  ${INPUTDIR}/${mcode}_${mver}.tif ${OUTPUTDIR}/${mcode}_${mver}.tif
      else
         echo "GeoTIFF map for ${code} (${mcode} ${mver}) is missing"
      fi
   fi

done < $LSTMAP
