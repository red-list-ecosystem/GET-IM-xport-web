export MIHOST=$(hostname -s)

export PROJECTNAME=GET-IM-xport-web
export PROJECTFOLDER=proyectos/IUCN-GET
export SCRIPTDIR=$HOME/$PROJECTFOLDER/$PROJECTNAME

case $MIHOST in
terra)
  export GISDATA=/opt/gisdata
  export GISDB=/opt/gisdb/ecosphere
  export WORKDIR=$HOME/tmp/$PROJECTNAME
  export REFDIR=$HOME/Cloudstor/Shared/EFTglobalmaps/
  source $HOME/.profile
  ;;
roraima)
  export GISDATA=$HOME/gisdata
  export GISDB=$HOME/gisdb/ecosphere
  export WORKDIR=$HOME/tmp/$PROJECTNAME
  export REFDIR=$HOME/Cloudstor/Shared/EFTglobalmaps/
  source $HOME/.profile
  ;;
*)
  echo "I DON'T KNOW WHERE I AM, please customize project-env.sh file"
  ;;
esac

export LOCATION=earth

mkdir -p $WORKDIR
grep -A4 psqlaws $HOME/.database.ini | tail -n +2 > tmpfile
while IFS="=" read -r key value; do
  case "$key" in
    "host") export DBHOST="$value" ;;
    "port") export DBPORT="$value" ;;
    "database") export DBNAME="$value" ;;
    "user") export DBUSER="$value" ;;
  esac
done < tmpfile
rm tmpfile


echo "
1 193 15 2 255
2 247 157 150 255
nv 0 0 0 0
" > $WORKDIR/DumparkMapColors.txt


export GTIFDIR=$WORKDIR/output-rasters/geotiff
export PSMDIR=$WORKDIR/output-rasters/psmercator
export MBXDIR=$WORKDIR/output-rasters/mapbox
export HGLDIR=$WORKDIR/output-vectors/hl-json

mkdir -p $GTIFDIR
mkdir -p $MBXDIR
mkdir -p $PSMDIR
mkdir -p $HGLDIR


#export ZIPDIR=$WORKDIR/zenodo_upload
#export XMLDIR=$WORKDIR/xml-output
#export PFLDIR=$WORKDIR/output-rasters/geotiff-eck4
#export PNGDIR=$WORKDIR/output-rasters/profile-png
#export JSNDIR=$WORKDIR/output-vectors/json

#mkdir -p $ZIPDIR
#mkdir -p $XMLDIR

#mkdir -p $PNGDIR
#mkdir -p $PFLDIR
#mkdir -p $JSNDIR
