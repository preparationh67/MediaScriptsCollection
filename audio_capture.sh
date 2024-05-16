#!/bin/bash
set -x
# ice or udp
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
# default 30 minutes
TIMELIMIT=1800
SAMPLE_RATE="96000"
FORMAT="s32_le"
# default off
TIMED=0
WAV_MODE=0
while [ -n "$1" ];do
        case "$1" in
                -t)
                        TIMELIMIT="$2"
                        TIMED=1
                        shift
                        ;;
                -T)
                        TIMED=1
                        echo "Using default time limit: $TIMELIMIT"
                        ;;
                -f)
                        if [[ $WAV_MODE -eq 0 ]]
                        then
                                FILENAME="$2.raw"
                        else
                                FILENAME="$2.wav"
                        fi
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
                        WAV_MODE=1
                        FILENAME=${FILENAME/.raw/.wav}
                        ;;

        esac
        shift
done
if [[ $WAV_MODE -eq 0 ]]
then
        if [[ $TIMED -eq 1 ]]
        then
                sudo nice -n -15 arecord -D $ALSA_HW -c 2 -r $SAMPLE_RATE -f $FORMAT -t raw -d $TIMELIMIT "$FILENAME"
        else
                sudo nice -n -15 arecord -D $ALSA_HW -c 2 -r $SAMPLE_RATE -f $FORMAT -t raw -d 0 "$FILENAME"
        fi
else
        if [[ $TIMED -eq 1 ]]
        then
                sudo nice -n -15 arecord -D $ALSA_HW -c 2 -r $SAMPLE_RATE -f $FORMAT -t wav -d $TIMELIMIT "$FILENAME"
        else
                sudo nice -n -15 arecord -D $ALSA_HW -c 2 -r $SAMPLE_RATE -f $FORMAT -t wav -d 0 "$FILENAME"
        fi

fi

# MP3 Version
#nice -n 15 arecord -D hw:0,0 -c 2 -r 192000 -f s32_le -t raw -d 0 | lame -r -s 192 --bitwidth 32 --signed --little-endian -V 0 -b 128 -B 320 - | ffmpeg "${ICE_OPTS[@]}"
