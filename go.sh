#!/bin/bash

pactl unload-module module-loopback;
pactl unload-module ladspa-sink;

	ffmpeg -i ${1}_voc.wav -i ${1}.wav -filter_complex \
"[0:a]anlmdn=s=25,\
equalizer=f=800:width_type=h:width=100:g=-6,\
deesser=f=0.95,\
ladspa=/usr/lib/ladspa/tap_autotalent.so:plugin=autotalent:c=440 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 1.0000,\
alimiter,\
speechnorm=e=50:r=0.0001:l=1,\
aecho=0.8:0.9:111:0.255,\
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,\
aresample=resampler=soxr:osf=s16[avoc];\
[1:a]aresample=resampler=soxr:osf=s16[a1];\
[avoc][a1]amix=inputs=2;"\
 ${1}_go.mp3 -y;



echo  "PLAY!";
mplayer ${1}_go.mp3;
