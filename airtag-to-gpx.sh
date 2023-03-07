#!/usr/bin/env bash


set -o pipefail -o nounset -o errexit

ARG1=${1:-""}

OUTPUT_DIR=${OUTPUT_DIR:-"$HOME/Desktop/airtag-gpx"}
TMP_DIR=${TMP_DIR:-"$OUTPUT_DIR/tmp-data"}
TODAY=$(date +%y%m%d)

# setup folders
mkdir -p $OUTPUT_DIR
mkdir -p $TMP_DIR

function get_all_airtag_names() {
   ALL_AIRTAGS="$(jq -r '.[] | select(.name) | .name' $HOME/Library/Caches/com.apple.findmy.fmipcore/Items.data)"
}

function read_single_airtag() {
   TAGNAME=${ARG1:-$single_airtag_name}
   GPX_TODAY=$TMP_DIR/$TAGNAME-$TODAY.gpx
   GPX=$TMP_DIR/$TAGNAME.gpx
   DATA_TODAY=$TMP_DIR/$TAGNAME-$TODAY.txt
   DATA=$TMP_DIR/$TAGNAME.txt
   
   jq -r '.[] | select(.name == "'$TAGNAME'") | .location | "\(.latitude) \(.longitude) \(.altitude) \(.timeStamp/1000 | todate)"' \
   $HOME/Library/Caches/com.apple.findmy.fmipcore/Items.data >> $DATA_TODAY
   cat $TMP_DIR/${TAGNAME}-*.txt | uniq > $DATA
}

function construct_gpx_header() {
   HEADER='<?xml version="1.0" encoding="UTF-8"?>
   <gpx xmlns="http://www.topografix.com/GPX/1/1" xmlns:mytracks="http://mytracks.stichling.info/myTracksGPX/1/0" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" creator="myTracks" version="1.1" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
      <trk>
         <name>'$TAGNAME'</name>
         <extensions>
            <mytracks:color red="0.000000" green="0.000000" blue="1.000000" alpha="1.000000" />
            <mytracks:area showArea="no" areaDistance="0.000000" />
            <mytracks:directionArrows showDirectionArrows="yes" />
            <mytracks:sync syncPhotosOniPhone="no" />
            <mytracks:timezone offset="120" />
         </extensions>
         <trkseg>'

   echo $HEADER > $GPX_TODAY 
   echo $HEADER > $GPX 
}

function construct_gpx_content(){
   IFS=${SAVEIFS:-$IFS}

   function elems() {
      LAT=$1
      LON=$2
      ELE=$3
      TS=$4
   }

   cat $DATA_TODAY | while read line; do
      elems $line
      echo '<trkpt lat="'$LAT'" lon="'$LON'">
                  <ele>'$ELE'</ele>
                  <time>'$TS'</time>
               </trkpt>' >> $GPX_TODAY
   done

   cat $DATA | while read line; do
      elems $line
      echo '<trkpt lat="'$LAT'" lon="'$LON'">
                  <ele>'$ELE'</ele>
                  <time>'$TS'</time>
               </trkpt>' >> $GPX
   done
}


function construct_gpx_footer(){
   FOOTER='      </trkseg>
      </trk>
   </gpx>'
   
   echo $FOOTER >> $GPX_TODAY
   echo $FOOTER >> $GPX
}


function cp_files(){
   cp $GPX $OUTPUT_DIR/$TAGNAME.gpx
   # rsync -a --exclude='*.txt' $TMP_DIR/ $OUTPUT_DIR/

}


#------------------------------------------------------------------

if [[ ! -z $ARG1 ]]; then
   # Single Airtag from $1
   read_single_airtag
   construct_gpx_header
   construct_gpx_content
   construct_gpx_footer
   cp_files
else
   # All
   get_all_airtag_names
   SAVEIFS=$IFS
   IFS=$(echo -en "\n\b")  # fix for whitespaces in ALL_AIRTAGS
   for single_airtag_name in $ALL_AIRTAGS; do
      IFS=$SAVEIFS
      read_single_airtag
      construct_gpx_header
      construct_gpx_content
      construct_gpx_footer
      cp_files
   done
fi