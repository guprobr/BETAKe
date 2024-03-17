#!/bin/bash

cd "${3}";
pwd;

### clean the mess left by betaREC
                killall -HUP pipewire-pulse;
                pactl unload-module module-loopback;
                pactl unload-module module-echo-cancel;
                pactl unload-module module-ladspa-sink;

PLAYBETA_TITLE="$( yt-dlp --get-title "${2}" )"; 
BETA_PLAYFILE="$( ls -1 playz/${1}_playback.* | head -n1 )";
BETA_TITLE="${PLAYBETA_TITLE}";

if [ "${1}" == "" ]; then
        echo INFORMAR O PARAMETROS, nome_KARAOKE
else
        if [ "${PLAYBETA_TITLE}" == "" ]; then
                BETA_TITLE="${1}"
        fi
fi
#### v2.7 - now it grabs video from webcam
#### v2.5: current version
#Since v2.0 live-processing for Autotalent, never worked.
#we just have to enhance already pitch corrected vocal with effects
#then MASTERIZE for streaming both playback and enhanced vocals, mixing both
PLAYBETA_LENGTH=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${3}recz/${1}_voc.avi" )
echo ${PLAYBETA_LENGTH}; echo ${BETA_TITLE};
#post-processing
echo "POST_PROCESSING____________________________________"
 
ffmpeg -y -loglevel info -hide_banner \
               -i "${3}${BETA_PLAYFILE}" \
        -ss 0.69s -i "${3}recz/${1}_voc.wav" \
        -filter_complex "[0:a]aresample=resampler=soxr:osf=s16:osr=44100,loudnorm=I=-16:LRA=11:TP=-1.5[play_back];
        [1:a]adeclip,anlmdn,afftdn,
        ladspa=tap_autotalent:plugin=autotalent:c=440 1.6726875 0.0000 0 0 0 0 0 0 0 0 0 0 0 0 0.25 1.00 0 0 0 0.33825 1.000 1.000 0 0 000.0 0.35,
        compand=points=-80/-105|-62/-80|-15.4/-15.4|0/-12|20/-7,
        aecho=0.8:0.7:96:0.13,
        aresample=resampler=soxr:osf=s16:osr=44100,
        loudnorm=I=-16:LRA=11:TP=-1.5[voc_enhanced];
        [play_back][voc_enhanced]amix=inputs=2:weights=0.4|0.55;" \
  -strict experimental \
        -ar 44100  \
                  -t ${PLAYBETA_LENGTH} "${3}/outz/${BETA_TITLE}_[BETAKe].wav" &

        sleep ${PLAYBETA_LENGTH};
        killall -9 ffmpeg;
        sleep 1;
        killall -9 ffmpeg;

ffmpeg -y -loglevel info -hide_banner \
        -i "${3}/outz/${BETA_TITLE}_[BETAKe].wav" \
        -i "${3}${BETA_PLAYFILE}.avi" \
        -i "${3}recz/${1}_voc.avi" \
        -filter_complex "
         [0:a]showcqt=s=300x120[cqt];
         [1:v]scale=s=300x120[v0];
         [1:a]avectorscope=m=polar:s=300x120[vscope];
          [2:v]scale=s=300x120[v1]; 
          [vscope][v1]hstack=inputs=2:shortest=1,scale=s=300x120[video_merge];
          [cqt][video_merge]vstack=inputs=2:shortest=1,format=rgba,colorchannelmixer=aa=0.34,scale=s=300x120[waveform];
          [v0][waveform]overlay=10:10:enable='gte(t,0)',format=rgba;" \
  -strict experimental \
        -ar 44100 -b:a 320k  \
                  -t ${PLAYBETA_LENGTH} "${3}/outz/${BETA_TITLE}_[BETAKe].mp4";

echo "fyn_PROCESSING____________________________________";
echo "PLAY";

ffplay -fs -loglevel info -hide_banner "${3}/outz/${BETA_TITLE}_[BETAKe].mp4"; 
#then PLAY! last successful output

# 2024 by gu.pro.br:weights=0.55|0.45,