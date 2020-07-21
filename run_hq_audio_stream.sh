#!/bin/bash
set -x
# ice or udp
RUN_MODE="ice"
OGGENC="~/vorbis-tools/oggenc/oggenc"
# capture options
SAMPLE_RATE="192000"
BITRATE="500k"
VORBIS_QUALITY="10"
BUFSIZE="1M"
THREADS=4
FFMPEG_OPTS=(-i - -acodec copy -f ogg -content_type audio/ogg)

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
        # REQUIRES PATCHED OGGENC FROM https://github.com/preparationh67/vorbis-tools
        nice -n -15 arecord -D $ALSA_HW -c 2 -r $SAMPLE_RATE -f s32_le -t raw -d 0 | $OGGENC -r -C 2 -B 32 -R $SAMPLE_RATE -q $VORBIS_QUALITY -b $BITRATE - | ffmpeg "${FFMPEG_OPTS[@]}" "${ICE_OPTS[@]}"
else
        nice -n -15 arecord -D $ALSA_HW -c 2 -r $SAMPLE_RATE -f s32_le -t raw -d 0 | $OGGENC -r -C 2 -B 32 -R $SAMPLE_RATE -q $VORBIS_QUALITY -b $BITRATE - | ffmpeg "${FFMPEG_OPTS[@]}" udp://$IPADDR:$PORT
fi

# MP3 Version
#nice -n 15 arecord -D hw:0,0 -c 2 -r 192000 -f s32_le -t raw -d 0 | lame -r -s 192 --bitwidth 32 --signed --little-endian -V 0 -b 128 -B 320 - | ffmpeg "${ICE_OPTS[@]}"

