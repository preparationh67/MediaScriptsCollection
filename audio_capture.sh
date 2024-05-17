#!/bin/bash
set -x
FILENAME="output.raw"
ALSA_HW='hw:1,0'
# 60 min - 3600
# 45 min - 2700
# 30 min - 1800
# 25 min - 1500
# 20 min - 1200
# 15 min - 900
# 10 min - 600
# 5 min - 300
# default infinite
TIMELIMIT=0
SAMPLE_RATE="96000"
FORMAT="s32_le"
DELAY=0
MODE="raw"
while [ -n "$1" ];do
        case "$1" in
                -t)
                        TIMELIMIT="$2"
                        shift
                        ;;
                -f)
                        FILENAME="$2.$MODE"
                        shift
                        ;;
                -a)
                        ALSA_HW="$2"
                        shift
                        ;;
                -s)
                        SAMPLE_RATE="$2"
                        shift
                        ;;
                -F)
                        FORMAT="$2"
                        shift
                        ;;
                -w)
                        MODE="wav"
                        FILENAME=${FILENAME/.raw/.wav}
                        ;;
                -d)
                        DELAY=$2
                        shift
                        ;;

        esac
        shift
done

if [[ $DELAY -gt 0 ]]
then
        sleep $DELAY
fi
sudo nice -n -15 arecord -D $ALSA_HW -c 2 -r $SAMPLE_RATE -f $FORMAT -t $MODE -d $TIMELIMIT "$FILENAME"


# MP3 Version
#nice -n 15 arecord -D hw:0,0 -c 2 -r 192000 -f s32_le -t raw -d 0 | lame -r -s 192 --bitwidth 32 --signed --little-endian -V 0 -b 128 -B 320 - | ffmpeg "${ICE_OPTS[@]}"
