#! /bin/bash
LSTMAP=$1

while IFS="|" read code mcode mver mtype status
do
   if [ -e ${MBXDIR}/${mcode}_${mver}.tif ]
   then
      echo "Map for ${code} (${mcode} ${mver}) already exists"
   else
      if [ -e ${GTIFDIR}/${mcode}_${mver}.tif ]
      then
         echo "reproject map for ${code} (${mcode} ${mver}) to pseudomercator"
         gdalwarp -t_srs EPSG:3857 -r near -co COMPRESS=LZW  -tr 2600 2600 -r mode ${GTIFDIR}/${mcode}_${mver}.tif ${MBXDIR}/${mcode}_${mver}.tif
      else
         echo "GeoTIFF map for ${code} (${mcode} ${mver}) is missing"
      fi
   fi
   if [ -e ${MBXDIR}/${mcode}_${mver}.mbtiles ]
   then
      echo "MBtiles file for ${code} (${mcode} ${mver}) already exists"
   else
      echo "translate map for ${code} (${mcode} ${mver}) to MBtiles"
      # this work for maps with two colors, but not for single category maps (like MFT1.2)
      gdal_translate -expand rgba ${MBXDIR}/${mcode}_${mver}.tif ${MBXDIR}/${mcode}_${mver}.mbtiles -of MBTILES
   fi
done < $LSTMAP
