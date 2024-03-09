#!/bin/bash

pactl unload-module module-loopback;
pactl unload-module ladspa-sink;

	ffmpeg -loglevel info -i ${1}_voc.wav -i ${1}.wav -filter_complex "\
[0:a]anlmdn=s=30,\
deesser=f=0.25,\
ladspa=/usr/lib/ladspa/tap_autotalent.so:plugin=autotalent:c=444 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0.05 1.0 1.0,\
aecho=0.8:0.9:100:0.3,\
speechnorm=e=6:r=0.0001:l=1,\
compand=points=-90/-90|-70/-70|-30/-15|0/-15|20/-15,\
equalizer=f=800:width_type=h:width=100:g=-3[avoc];\
[avoc][1:a]amix=inputs=2:weights=0.7|0.3;\
" ${1}_go.mp3 -y;



echo  "PLAY!";
mplayer ${1}_go.mp3;
