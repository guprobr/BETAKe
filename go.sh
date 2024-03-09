#!/bin/bash

pactl unload-module module-loopback;
pactl unload-module ladspa-sink;

	ffmpeg -loglevel info -i ${1}_voc.wav -i ${1}.wav -filter_complex "\
[0:a]anlmdn=s=30,\
equalizer=f=800:width_type=h:width=100:g=-3,\
deesser=f=1.0,\
ladspa=/usr/lib/ladspa/tap_autotalent.so:plugin=autotalent:c=444 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0.05 1.0 1.0,aecho=0.8:0.9:1000:0.3,speechnorm=e=8:r=0.0001:l=1[avoc];\
[avoc][1:a]amix=inputs=2:weights=0.7|0.3[amixed];\
[amixed]compand=points=-80/-105|-62/-80|-15.4/-15.4|0/-12|20/-7[w]\
" -map "[w]" ${1}_go.mp3 -y;

echo  "PLAY!";
mplayer ${1}_go.mp3;
