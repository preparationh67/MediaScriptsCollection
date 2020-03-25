#!/bin/bash
set -x
# ice or udp
RUN_MODE="ice"
ENCODE_MODE="vorbis"
# capture options
SAMPLE_RATE="48000"
OUTPUT_BITRATE="256k"
FFMPEG_OPTS=(-f alsa -i hw:0 -ac 2 -ar $SAMPLE_RATE)
# Unused options, maybe useful
#-tune zerolatency
#-re

if [ "$ENCODE_MODE" == "mp3" ]
then
	FFMPEG_OPTS+=(-acodec libmp3lame -ab $OUTPUT_BITRATE -content_type audio/mpeg -f mp3)
else
	FFMPEG_OPTS+=(-acodec libvorbis -ab "256k" -compression_level 10 -application audio -content_type audio/ogg -f ogg)
fi

# udp options
IPADDR="0.0.0.0"
PORT="8001"
# ice options
ICE_ADDR="127.0.0.1"
ICE_PORT="8000"
ICE_USER="source"
ICE_PASS="%YOUR_ICECAST_PASSWORD%"
ICE_MOUNT="hifi"
ICE_URL="http://example.com/$ICE_MOUNT"
ICE_NAME='Example Stream'
ICE_DESC='Example of streaming output'
ICE_GENRE='Various'
ICE_CAST="icecast://$ICE_USER:$ICE_PASS@$ICE_ADDR:$ICE_PORT/$ICE_MOUNT"
ICE_OPTS=( -ice_name "${ICE_NAME}" -ice_description "${ICE_DESC}" -ice_url "${ICE_URL}" -ice_genre "${ICE_GENRE}" "${ICE_CAST}" )

if [ "$RUN_MODE" == "ice" ]
then
        nice -n -15 ffmpeg ${FFMPEG_OPTS[@]} "${ICE_OPTS[@]}"
else
        nice -n -15 ffmpeg ${FFMPEG_OPTS[@]} udp://$IPADDR:$PORT
fi
