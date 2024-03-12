#!/bin/bash

pactl unload-module module-loopback;
pactl unload-module ladspa-sink;

ffmpeg -y -hide_banner -i ${1}_voc.wav -i ${1}.wav -filter_complex "

[0:a]
adeclip,
anlmdn=s=128,
compand=points=-80/-105|-62/-80|-15.4/-15.4|0/-12|20/-7,
speechnorm=e=8:r=0.0001:l=1,
deesser,
ladspa=tap_autotalent:plugin=autotalent:
c=440 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 
1 1 0 0 
0.000 0 
0.000 0.000 0.000 
1.0,
treble=g=5,
equalizer=f=150:width_type=h:width=100:g=3,
equalizer=f=800:width_type=h:width=100:g=-3,
equalizer=f=5000:width_type=h:width=100:g=3,

loudnorm=I=-16:LRA=11:TP=-1.5,
aecho=0.8:0.9:169:0.2,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[enhanced];

[1:a]
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[audio];
[audio][enhanced]amix=inputs=2:weights=0.3|0.7;
" -ar 44100 ${1}_go.wav && mplayer ${1}_go.wav;
