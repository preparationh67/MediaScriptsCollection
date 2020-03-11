#!/bin/bash
default_mount="example.ogg"
default_artist="Example Artist"
default_song="Example Song"
web_admin="admin"
web_pass="%YOUR_ICE_ADMIN_PASSWORD%"
web_server="localhost"
web_port="8000"

param_artist=""
param_song=""
param_mount=""
last_param=""

while [ -n "$1" ]; do
        case "$1" in
        -a)
                param_artist+="$2"
                last_param="artist"
                shift
                ;;
        -s)
                param_song+="$2"
                last_param="song"
                shift
                ;;
        -m)
                param_mount="$2"
                last_param="mount"
                shift
                ;;
        -h)
                echo "Usage: $0 -a <Artist Name> -s <Song Name> -m <Icecast Mount Name>"
                exit 0
                ;;
        *)
                if [ "$last_param" == "artist" ]
                then
                        param_artist+="+$1"
                elif [ "$last_param" == "song" ]
                then
                        param_song+="+$1"
                else
                        echo "ERROR!"
                        exit 1
                fi
                ;;
        esac
        shift
done

artist="${param_artist:-$default_artist}"
song="${param_song:-$default_song}"
artist=${artist// /+}
song=${song// /+}
web_mount="${param_mount:-$default_mount}"

echo  "http://$web_admin:$web_pass@$web_server:$web_port/admin/metadata?mount=/$web_mount&mode=updinfo&artist=$artist&title=$song"
curl "http://$web_admin:$web_pass@$web_server:$web_port/admin/metadata?mount=/$web_mount&mode=updinfo&artist=$artist&title=$song"
