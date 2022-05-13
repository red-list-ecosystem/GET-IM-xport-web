#! /bin/bash
LSTMAP=$1
INPUTDIR1=$2
INPUTDIR2=$3
OUTPUTDIR=$4

while IFS="|" read code mcode mver mtype status
do
   MAPCODE=${mcode}_${mver}
   if [ -e ${INPUTDIR1}/${MAPCODE}.tif ]
   then
      if [ -e ${INPUTDIR2}/${MAPCODE}.json ]
      then
         if [ -e ${OUTPUTDIR}/${MAPCODE}.mbtiles ]
         then
            echo "MBtiles file for ${code} (${MAPCODE}) already exists"
         else
            if [ -e ${OUTPUTDIR}/${MAPCODE}_crop.tif ]
            then
               echo "Map for ${code} (${MAPCODE}) already cropped to highlight buffer"
            else
               echo "crop map for ${code} (${MAPCODE}) using highlight buffer"
               BBX=$(ogrinfo -al -so ${INPUTDIR2}/${MAPCODE}.json | grep Extent | sed -e "s/[A-Za-z:()\,]\+//g" -e "s/ - / /g")
               gdalwarp -te $BBX -r near -dstnodata 0 -ot Byte ${INPUTDIR1}/${MAPCODE}.tif ${OUTPUTDIR}/${MAPCODE}_crop.tif
               gdaldem color-relief ${OUTPUTDIR}/${MAPCODE}_crop.tif $WORKDIR/DumparkMapColors.txt ${OUTPUTDIR}/${MAPCODE}_color.tif -alpha

            fi
            # add mbtiles (smaller size) with overviews
            echo "translate map for ${code} (${MAPCODE}) to MBtiles"
            gdal_translate  ${OUTPUTDIR}/${MAPCODE}_color.tif ${OUTPUTDIR}/${MAPCODE}.mbtiles -of MBTILES
            gdaladdo -r nearest ${OUTPUTDIR}/${MAPCODE}.mbtiles 2 4 8 16
         fi
      else
         echo "Highlight vector for ${code} (${MAPCODE}) not found "
      fi
   else
      echo "Map for ${code} (${MAPCODE}) not found "
   fi
done < $LSTMAP
