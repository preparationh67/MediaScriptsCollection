#!/bin/bash
set -x
# ice or udp
RUN_MODE="ice"

# capture options
SAMPLE_RATE="19200"
OUTPUT_BITRATE="500k"
VORBIS_QUALITY="10"
BUFSIZE="1M"
THREADS=4
#FFMPEG_OPTS=(-f alsa -i hw:0 -ac 2 -ar $SAMPLE_RATE -threads $THREADS)
# Unused options, maybe useful
#-tune zerolatency
#-re
FFMPEG_OPTS=(-acodec pcm_s32le -ac 2 -i - -f ogg -acodec libvorbis -ab $OUTPUT_BITRATE  -q $VORBIS_QUALITY -content_type audio/ogg -threads $THREADS)

# udp options
IPADDR="0.0.0.0"
PORT="8001"
# ice options
ICE_ADDR="127.0.0.1"
ICE_PORT="8000"
ICE_USER="source"
ICE_PASS="%ICEPASSWORD%"
ICE_MOUNT="hifihq"
ICE_URL="http://radio.example.com/$ICE_MOUNT"
ICE_NAME='Example Stream'
ICE_DESC='Example Stream Description'
ICE_GENRE='Various'
ICE_CAST="icecast://$ICE_USER:$ICE_PASS@$ICE_ADDR:$ICE_PORT/$ICE_MOUNT"
ICE_OPTS=( -ice_name "${ICE_NAME}" -ice_description "${ICE_DESC}" -ice_url "${ICE_URL}" -ice_genre "${ICE_GENRE}" "${ICE_CAST}" )

ALSA_HW='hw:0,0'

if [ "$RUN_MODE" == "ice" ]
then
        nice -n 15 arecord -D $ALSA_HW -c2 -r$SAMPLE_RATE --disable-resample -fs32_le | ffmpeg ${FFMPEG_OPTS[@]} "${ICE_OPTS[@]}"
else
        nice -n -15 arecord -D $ALSA_HW -c2 -r$SAMPLE_RATE --disable-resample -fs32_le | ffmpeg ${FFMPEG_OPTS[@]} udp://$IPADDR:$PORT
fi
