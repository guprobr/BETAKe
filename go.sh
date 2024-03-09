#!/bin/bash

pactl unload-module module-loopback;
pactl unload-module ladspa-sink;

		ffmpeg -loglevel info -i ${1}_voc.wav -i ${1}.wav -filter_complex "\
[0:a]anlmdn=s=15,\
equalizer=f=800:width_type=h:width=100:g=-3,\
deesser=f=1.0,\
ladspa=/usr/lib/ladspa/tap_autotalent.so:plugin=autotalent:c=440 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0.35,aecho=0.8:0.9:55:0.255,speechnorm=e=8:r=0.0001:l=1[avoc];\
[avoc][1:a]amix=inputs=2:weights=0.6|0.4"\
							${1}_go.mp3 -y;

# [amixed]compand=points=-80/-105|-62/-80|-15.4/-15.4|0/-12|20/-7" 

echo  "PLAY!";
mplayer ${1}_go.mp3;
