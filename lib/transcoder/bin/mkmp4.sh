#! /bin/bash

# This bash script has been created by Diego Massanti
# You are free and welcome to do whatever you want with it.
# www.massanti.com

usage()
{
cat << EOF
usage: $0 -f <file to encode> [-w <integer>] -b <integer> [-q][-k]

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* h264 video with he-aac audio encoding script by Diego Massanti. *
*                January 2008, Made in Argentina.                 *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

OPTIONS:
   	-h	Show this message
	-f	Path to the file to encode < REQUIRED
   	-w	Resize video to fit inside this width while keeping the aspect ratio < OPTIONAL
   	-b	Desired video bitrate < REQUIRED
   	-q 	Better quality encoding using 2 passes (slower) < OPTIONAL
	-k	Do not delete (keep) temporary files < OPTIONAL
EOF
}
audiobitrate=48000
platform=""
uname=`uname`
if [ $uname == "Darwin" ]; then
	## 99% of chances that this is a Mac
	platform="Mac"
else
	platform="Linux"
fi

width=""
bitrate=
deltemp=TRUE
quality=FALSE
filename=
rsize=""

while getopts ":f:w:b:qkv" OPTION; do
  case $OPTION in
    w ) width=$OPTARG;;
	f ) filename=$OPTARG;;
    b ) bitrate=$OPTARG;;
    k ) deltemp=FALSE;;
	q )	quality=TRUE;;
    h ) usage;;
    \? ) usage
         exit 1;;
    * ) echo $usage
          exit 1;;
  esac
done

if [ "$1" == "" ]; then
	usage
	exit 0
fi

if [ "$filename" == "" ]; then
	echo
	echo you MUST supply a file to encode!, use the -f parameter. i.e: -f mymovie.avi
	echo
	usage
	exit 1
fi
if [ "$bitrate" == "" ]; then
	echo
	echo you MUST specify a target bitrate!, use the -b parameter. i.e: -b 512
	echo
	usage
	exit 1
fi

if [ "$width" != "" ]; then
	rsize="-vf scale=$width:-3"
	rsizemsg="fit into $width pixels wide"
else
	rsize=""
	rsizemsg="Movie is not being resized."
fi

MOVIE_FPS=`midentify "$filename" | grep FPS | cut -d = -f 2`
#clear
echo "*    Encoding: $filename"
echo "*    Resizing to: $rsizemsg."
echo "*    Total Bitrate: $bitrate kbps."
let "caudiobitrate = $audiobitrate / 1000"
let "bitrate = $bitrate - $caudiobitrate"
echo "*    Video Bitrate: $bitrate kbps."
echo "*    Audio Bitrate: $caudiobitrate kbps."
echo "*    Platform: $platform."


# Encoding phase starts here...
# Encoding Video...
echo "* * * Starting video encoding pass 1... * * *"
#mencoder "$filename" -o "${filename%.*}_temp.264" -ovc x264 -x264encopts bitrate=$bitrate:frameref=8:bframes=3:b_adapt:b_pyramid:weight_b:partitions=all:8x8dct:me=umh:subq=6:trellis=2:brdo:threads=auto:pass=1:analyse=all -of rawvideo -nosound
ffmpeg -y -i "$filename" -an -pass 1 -vcodec libx264 -b 384k -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -flags2 +mixed_refs -me umh -subq 5 -trellis 1 -refs 3 -bf 3 -b_strategy 1 -coder 1 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 384k -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.8 -qmin 10 -qmax 51 -qdiff 4 "${filename%.*}_temp.mp4"
#if [ "$quality" == "TRUE" ]; then
echo "* * * Starting video encoding pass 2... * * *"
#mencoder "$filename" -o "${filename%.*}_temp.264" -passlogfile "${filename%.*}"_temp.log $rsize -ovc x264 -x264encopts bitrate=$bitrate:frameref=8:bframes=3:b_adapt:b_pyramid:weight_b:partitions=all:8x8dct:me=umh:subq=6:trellis=2:brdo:threads=auto:pass=2:analyse=all -of rawvideo -nosound
ffmpeg -y -i "$filename" -an -pass 2 -vcodec libx264 -b 384k -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -flags2 +mixed_refs -me umh -subq 5 -trellis 1 -refs 3 -bf 3 -b_strategy 1 -coder 1 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 384k -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.8 -qmin 10 -qmax 51 -qdiff 4 "${filename%.*}_temp.mp4"
#fi
mv "${filename%.*}_temp.mp4" "${filename%.*}_temp.264"

# Extracting audio to a 48khz WAV file.
echo "* * * Extracting Audio... * * *"
#mplayer "$filename" -af resample=48000:0:2,volnorm=2:0.25 -ao pcm:file="${filename%.*}_temp.wav" -vc dummy -vo null
ffmpeg -i "$filename"  -ar 48000 -ac 2 "${filename%.*}_temp.wav"

# Encoding Audio to HE-AAC plus file
echo "* * * Encoding Audio... * * *"

if [ "$platform" == "Mac" ]; then
enhAacPlusEnc "${filename%.*}_temp.wav" "${filename%.*}_temp.aac" $audiobitrate s
else
neroAacEnc -br 48000 -he -if ${filename%.*}_temp.wav -of ${filename%.*}_temp.mp4
fi

# Muxing
echo "* * * Generating final MP4 container... * * *"

MP4Box -add "${filename%.*}_temp.264#video:fps=$MOVIE_FPS" "${filename}.m4v"
if [ "$platform" == "Mac" ]; then
MP4Box -add "${filename%.*}_temp.aac" "${filename}.m4v"
else
MP4Box -add "${filename%.*}_temp.mp4#audio" "${filename}.m4v"
fi

# MetaData and interleaving
name=${filename%.*}
album="Some Album"
author="Some Author"
comment="Professionally encoded using ffmpeg, x264 and GPAC Utilies"
created="2007"
MP4Box -inter 500 -itags album="$album":artist="$author":comment="$comment":created="$created":name="$name" -lang English "${filename}.m4v"

# Clean up temporary files...
if [ $deltemp == "TRUE" ]; then
	echo "* * * Removing temporary files... * * *"
	rm "${filename%.*}"_temp*
fi
