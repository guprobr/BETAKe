#!/bin/bash

pactl unload-module module-loopback;
pactl unload-module ladspa-sink;

	ffmpeg -loglevel info -i ${1}_voc.wav -i ${1}.wav -filter_complex "\
[0:a]anlmdn=s=30,\
equalizer=f=800:width_type=h:width=100:g=-3,\
ladspa=/usr/lib/ladspa/tap_autotalent.so:plugin=autotalent:c=444 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0.05 1.0 1.0,\
deesser=f=0.25,\
aecho=0.5:0.6:100:0.3,\
speechnorm=e=6:r=0.0001:l=1,\
compand=points=-90/-90|-70/-70|-30/-15|0/-15|20/-15[avoc];\
[1:a]volume=volume=-20dB[a1];\
[avoc]volume=volume=-15dB[a2];\
[a1][a2]amix=inputs=2:weights=1|1[audio]\
" ${1}_go.mp3 -y;



echo  "PLAY!";
mplayer ${1}_go.mp3;
