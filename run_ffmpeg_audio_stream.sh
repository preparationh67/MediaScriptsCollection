#/bin/bash
set -x
# ice or udp
RUN_MODE="ice"

# capture options
SAMPLE_RATE="48000"
OUTPUT_BITRATE="320k"
BUFSIZE="1M"
FFMPEG_OPTS=(-f alsa -i hw:0 -ac 2 -ar $SAMPLE_RATE -acodec libmp3lame -ab $OUTPUT_BITRATE -bufsize $BUFSIZE -content_type audio/mpeg -f mp3)
# Unused options, maybe useful
#-tune zerolatency
#-re

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
        ffmpeg ${FFMPEG_OPTS[@]} "${ICE_OPTS[@]}"
else
        ffmpeg ${FFMPEG_OPTS[@]} udp://$IPADDR:$PORT
fi
