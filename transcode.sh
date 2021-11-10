#!/bin/bash

if [ -z $1 ]; then
    echo "No input file specified"
    exit
fi

echo -n "Enable HDR support? "
DEFAULT="n"
read -e -p "[y/N]: " HDR
# adopt the default, if 'enter' given
HDR="${HDR:-${DEFAULT}}"
# change to lower case to simplify following if
HDR="${HDR,,}"

echo -n "Select CRF (0: lossless, 51: worst quality) "
if [ "${HDR}" == "y" ] ; then
  DEFAULT=18
else
  DEFAULT=20
fi
read -e -p "[$DEFAULT]: " CRF
# adopt the default, if 'enter' given
CRF="${CRF:-${DEFAULT}}"

echo -n "Encoder Preset: "
DEFAULT="veryfast"
read -e -p "[$DEFAULT]: " PRESET
PRESET="${PRESET:-${DEFAULT}}"

echo -n "Output name: "
DEFAULT=$(basename "$1" | sed 's/\(.*\)\..*/\1/')
read -e -p "[$DEFAULT]: " OUTPUT
OUTPUT="${OUTPUT:-${DEFAULT}}"


echo ""
echo "--- OVERVIEW ---"

if [ "${HDR}" == "y" ] ; then
  echo "HDR: Yes"
else
  echo "HDR: No"
  # do proceeding code in here
fi

echo "CRF: ${CRF}"
echo "Preset: ${PRESET}"
echo "Output file: ${OUTPUT}.mkv"

echo -n "Start transcoding? "
DEFAULT="y"
read -e -p "[Y/n]: " START
# adopt the default, if 'enter' given
START="${START:-${DEFAULT}}"
# change to lower case to simplify following if
START="${START,,}"
if [ "${START}" != "y" ] ; then
  exit
fi

echo "Starting transcode process..."

if [ "${HDR}" == "y" ] ; then
  ffmpeg -loglevel quiet -stats -hide_banner -i "$1" -pix_fmt yuv420p10le -metadata title="$OUTPUT" -map 0:v -map 0:a -map 0:s -c:v libx265 -preset $PRESET -crf $CRF -c:a copy -c:s copy -map_metadata 0 -disposition:s -default -default_mode infer_no_subs -x265-params keyint=60:bframes=3:vbv-bufsize=75000:vbv-maxrate=75000:hdr-opt=1:repeat-headers=1:colorprim=bt2020:transfer=smpte2084:colormatrix=bt2020nc:master-display="G(13250,34500)B(7500,3000)R(34000,16000)WP(15635,16450)L(10000000,500)" "$OUTPUT.mkv"
  
  
else
  ffmpeg -loglevel quiet -stats -hide_banner -i "$1" -metadata title="$OUTPUT" -map 0:v -map 0:a -map 0:s -c:v libx265 -preset $PRESET -crf $CRF -c:a copy -c:s copy -map_metadata 0 -disposition:s -default -default_mode infer_no_subs "$OUTPUT.mkv" 
fi
