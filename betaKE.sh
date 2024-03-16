#!/bin/bash

### clean the mess left by betaREC
                killall -HUP pipewire-pulse;
                pactl unload-module module-loopback;
                pactl unload-module module-echo-cancel;
                pactl unload-module module-ladspa-sink;

BETA_TITLE="${2}";

if [ "${1}" == "" ]; then
        echo INFORMAR DOIS PARAMETROS, nome_playback sem extensao WAV e TITULO mp3;
else
        if [ "${2}" == "" ]; then
                BETA_TITLE="${1}"
        fi
fi

#### v2.5: current version
#Since v2.0 live-processing for Autotalent, never worked.
#we just have to enhance already pitch corrected vocal with effects
#then MASTERIZE for streaming both playback and enhanced vocals, mixing both
#
#post-processing
ffmpeg -y -hide_banner -ss 0.36 -i recz/"${1}_voc.wav" -i playz/"${1}.wav" -i playz/"${1}_playback.webm" -filter_complex "
[0:a]adeclip,
anlmdn=s=33,highpass=f=100,lowpass=f=15000,
ladspa=tap_autotalent:plugin=autotalent:c=440 1.6726875 0.0000 0 0 0 0 0 0 0 0 0 0 0 0 0.25 1.00 0 0 0 0.33825 1.000 1.000 0 0 000.0 0.35,
compand=points=-80/-105|-62/-80|-15.4/-15.4|0/-12|20/-7,
firequalizer=gain_entry='entry(250,-5);entry(4000,3)',
firequalizer=gain_entry='entry(-10,0);entry(10,2)',
aecho=0.8:0.7:111:0.13,treble=g=5,
loudnorm=I=-16:LRA=11:TP=-1.5,volume=volume=5dB,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[voc_master];
[1:a]
loudnorm=I=-16:LRA=11:TP=-1.5,volume=volume=5dB,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[play_master];
[play_master][voc_master]amix=inputs=2,
afade=t=in:st=0:d=2;

[0:a]showcqt=size=320x200[cqt]; [1:a]avectorscope=size=320x200[ascope];
[ascope][cqt]overlay[viz] ; [2:v]scale=1920x1080[scoop]; 
[scoop]colorchannelmixer=aa=0.8[tux]; [viz][tux]overlay=10:3
" -strict experimental -ar 44100 -acodec aac -b:a 320k \
                                recz/"${2}_[BETAKe].mp4"

mplayer recz/"${2}_[BETAKe].mp4"; #then PLAY!

# 2024 by gu.pro.br
