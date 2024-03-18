#!/bin/bash

cd "${3}";
pwd;

echo '[betaKE.sh]'
echo -e "\e[90mclean the mess left by betaREC\e[0m"
                killall -HUP pipewire-pulse;
                pactl unload-module module-loopback;
                pactl unload-module module-echo-cancel;
                pactl unload-module module-ladspa-sink;

PLAYBETA_TITLE="$( yt-dlp --get-title "${2}" )"; 
BETA_PLAYFILE="$( ls -1 ${3}playz/${1}_playback.* | head -n1 )";
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
echo ${PLAYBETA_LENGTH}; echo ${BETA_TITLE}; echo "${BETA_PLAYFILE}";
#post-processing
echo "POST_PROCESSING____________________________________"
 echo -e "\e[90mrendering audio mix\e[0m"
ffmpeg -y -hide_banner -loglevel info  -i "${BETA_PLAYFILE}" -i "${3}recz/${1}_voc.wav" \
        -filter_complex "
[1:a]anlmdn=s=33,speechnorm,
ladspa=tap_autotalent:plugin=autotalent:c=440 0 0.0000 0 0 0 0 0 0 0 0 0 0 0 0 1.000 1.00 0 0 0 0 1.000 1.000 0 0 000.0 1.000,
compand=points=-80/-105|-62/-80|-15.4/-15.4|0/-12|20/-7,
firequalizer=gain_entry='entry(250,-5);entry(4000,3)',
firequalizer=gain_entry='entry(-10,0);entry(10,2)',
aecho=0.8:0.7:111:0.13,
extrastereo=m=1.5,lowpass=3000,highpass=200,treble=g=5,
dynaudnorm=p=1:s=12:g=15,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[voc_master];
[0:a]
dynaudnorm=p=1:s=12:g=15,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[play_master];

[play_master][voc_master]amix=inputs=2,
afade=t=in:st=0:d=2;" -ar 48k "${3}outz/${BETA_TITLE}_[BETAKe].wav";

echo -e "\e[90mrendering video frames\e[0m"
ffmpeg -y -loglevel info -hide_banner \
        -i "${3}outz/${BETA_TITLE}_[BETAKe].wav" \
        -i "${BETA_PLAYFILE}" \
        -i "${3}recz/${1}_voc.avi" \
        -filter_complex "
         [1:v]scale=s=400x260[v0];
         [0:a]showspatial=s=400x260[spats];
         [1:a]avectorscope=m=polar:s=400x260[vscope];
          [2:v]scale=s=400x260[v1]; 
          [vscope][v1]hstack=inputs=2,scale=s=400x260[video_merge];
          [spats][video_merge]vstack=inputs=2,format=rgba,colorchannelmixer=aa=0.34,scale=s=400x260[waveform];
          [v0][waveform]overlay=10:10:enable='gte(t,0)',format=rgba,scale=s=1920x1080;" \
                                -strict experimental -an "${3}outz/${BETA_TITLE}_[BETAKe].avi" ;
 echo -e "\e[90merging audio + video\e[0m";
 echo "We do in separate steps because of a bug which conversion hangs because of bad PCM";
ffmpeg -y -loglevel info -hide_banner \
        -i "${3}outz/${BETA_TITLE}_[BETAKe].wav" \
        -i "${3}outz/${BETA_TITLE}_[BETAKe].avi" \
             -acodec libmp3lame -ar 48k -b:a 320k \
             -c:v libx264 -b:v 933k -preset:v veryfast "${3}outz/${BETA_TITLE}_[BETAKe].mp4" ;

ffplay -fs -loglevel quiet -hide_banner "${3}outz/${BETA_TITLE}_[BETAKe].mp4";


# 2024 by gu.pro.br:weights=0.55|0.45,