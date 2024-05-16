#!/bin/bash
set -x
if [ "$1" == "" ]
then
        FILENAME="output.raw"
else
        FILENAME="$1.raw"
fi
SAMPLE_RATE="96000"
BITRATE="500"
VQ="10"
BUFSIZE="4M"
THREADS=4
ALSA_HW='hw:1,0'
sudo nice -n -15 arecord -D $ALSA_HW -c 2 -r $SAMPLE_RATE -f s32_le -t raw -d 0 "$FILENAME"

# MP3 Version
#nice -n 15 arecord -D hw:0,0 -c 2 -r 192000 -f s32_le -t raw -d 0 | lame -r -s 192 --bitwidth 32 --signed --little-endian -V 0 -b 128 -B 320 - | ffmpeg "${ICE_OPTS[@]}"
