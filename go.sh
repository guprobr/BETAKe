#!/bin/bash

pactl unload-module module-loopback;
pactl unload-module ladspa-sink;

	ffmpeg -i ${1}_voc.wav -i ${1}.wav -filter_complex \
"[0:a]anlmdn=s=10,\
ladspa=/usr/lib/ladspa/tap_autotalent.so:plugin=autotalent:c=440.000 0.000 0.000 0 -1 0 -1 0 0 -1 0 -1 0 -1 0 1.000 1.000 0.000 0 0.000 0.000 1.000 1.000 0.000 1.00,\
deesser=f=0.1,\
dynaudnorm,\
speechnorm,\
aecho=0.5:0.6:100:0.3,\
compand=points=-90/-90|-70/-70|-30/-15|0/-15|20/-15,\
equalizer=f=100:width_type=q:width=2:g=-3,\
chorus=0.7:0.9:55:0.4:0.25:2,\
highpass=f=100,lowpass=f=15000,\
stereowiden,\
acontrast,\
alimiter=level_in=0.5:attack=0.1:release=1,\
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,\
aresample=resampler=soxr:osf=s16,volume=volume=0.2dB[avoc];\
[1:a]aresample=resampler=soxr:osf=s16,volume=volume=-2dB[a1];\
[avoc][a1]amix=inputs=2:weights=1.0|0.6;"\
 ${1}_go.mp3 -y;



echo  "PLAY!";
mplayer ${1}_go.mp3;
