# GET-IM-xport-web
IUCN Global Ecosystem Typology - Indicative maps L3 - export to GitHub and Mapbox repositories for inclusion in the website

We have maps created in Grass GIS, but also some created in Katana using GDAL and OGR tools, R scripts or EarthEngine scripts. There are different map version for each functional group, some of these maps have been uploaded in mapbox or in the global-ecosystems repository as topojson files.

## Set up programing environment and output directories

```sh
source $HOME/proyectos/IUCN-GET/GET-IM-xport-web/env/project-env.sh
cd $WORKDIR
```

## Copy GeoTIFF files from other repos

Let's check all these repos to get alllllll... versions of the maps.
```sh
rsync -gloptrunv $HOME/tmp/GET-indicative-maps-GIS/output-GeoTiff/*tif $GTIFDIR
rsync -gloptrunv  $HOME/tmp/GET-indicative-maps/output-rasters/geotiff/*tif $GTIFDIR
rsync -gloptrunv  $HOME/tmp/GET-IM-xport-zenodo/output-rasters/geotiff/*tif $GTIFDIR
rsync -gloptrunv $zID@kdm.restech.unsw.edu.au:/srv/scratch/z3529065/tmp/GET-indicative-maps-GIS/output-GeoTiff/*tif $GTIFDIR
```

Also get those already prepared for mapbox

```sh
rsync -gloptrunv  $HOME/tmp/GET-indicative-maps/output-rasters/mapbox/*tif $MBXDIR
rsync -gloptrunv  $HOME/tmp/GET-indicative-maps/output-rasters/mapbox/*mbtiles $MBXDIR
```

Check results:
```sh
tree output-rasters/

```


## Copy GeoJSON files from other repos

Do the same for json files
```sh
rsync -gloptrunv  $HOME/tmp/GET-indicative-maps/output-hl-json/*json $HGLDIR
```


Check results:
```sh
tree output-vectors/

```

## Export GeoTIFF files from Grass GIS database

First create a list of all maps to process:
```sh
psql -At -h $DBHOST -d $DBNAME -U $DBUSER -c "SELECT code, map_code, map_version, map_type, status FROM map_metadata WHERE status='valid' ORDER BY map_type,code " > raster-maps.list
```

## Reproject GeoTIFF files to Web Mercator EPSG:3857

We use this script to reproject a selection of maps:

```sh
cd $WORKDIR

EFG=WM.nwx
##EFG=MT2.2
EFG=F1.6.IM.mix
EFG=M1.10
EFG=T7.5

grep $EFG raster-maps.list > slc.maps
$SCRIPTDIR/inc/bash/geotiff-reprojection-for-mapbox.sh slc.maps


#nohup $SCRIPTDIR/inc/bash/geotiff-reprojection-for-mapbox.sh slc.maps > nohup-geotiff-reproject-${EFG}.out &

```

## Create highlight buffer

First create the highlight buffer in the pseudomercator projection:

```sh
cd $WORKDIR
conda deactivate

rm -r $GISDATA/tmploc

grass -c $MBXDIR/MFT1.2.WM.nwx_v1.0.tif $GISDATA/tmploc --exec bash $SCRIPTDIR/inc/bash/create-highlight-buffer.sh slc.maps $MBXDIR $HGLDIR
```

Now we need to reproject to plate carré and simplify, something like this...

```sh
ogr2ogr -f GeoJSON -s_srs "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs" -t_srs EPSG:4326 $OUTDIR/prueba_ll.json $INPUTMAP
geo2topo -q 1e5 -o $OUTDIR/prueba-topo.json $OUTDIR/prueba_ll.json
```

This has to be copied to the repository:

```sh
 OUTPUTMAP=$HOME/proyectos/UNSW/typology-map-data/data/auxiliary/${EFG}_buffer.topo.json
 mv $OUTDIR/prueba-topo.json $OUTPUTMAP
```


jrfep.T2_2_web_mix
