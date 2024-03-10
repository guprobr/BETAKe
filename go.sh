#!/bin/bash

pactl unload-module module-loopback;
pactl unload-module ladspa-sink;

	ffmpeg -i ${1}_voc.wav -i ${1}.wav -filter_complex \
"[0:a]anlmdn=s=30,\
ladspa=/usr/lib/ladspa/tap_autotalent.so:plugin=autotalent:c=440.000 0.000 0.000 0 -1 0 -1 0 0 -1 0 -1 0 -1 0 0.5 1.00 0.000 0 0.000 0.000 0.000 0.000 0.000 1.000,\
deesser=f=0.05,\
dynaudnorm,\
speechnorm,\
compand=points=-90/-90|-70/-70|-30/-15|0/-15|20/-15,\
equalizer=f=100:width_type=q:width=2:g=-3,\
highpass=f=100,lowpass=f=15000,\
stereowiden,\
acontrast,\
alimiter=level_in=0.5:attack=0.1:release=1,\
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,\
aresample=resampler=soxr:osf=s16[avoc];\
[1:a]aresample=resampler=soxr:osf=s16[a1];\
[avoc][a1]amix=inputs=2:weights=1.0|0.25;"\
 ${1}_go.mp3 -y;



echo  "PLAY!";
mplayer ${1}_go.mp3;
