#!/bin/bash

pactl unload-module module-loopback;
pactl unload-module ladspa-sink;

ffmpeg -y -hide_banner -i ${1}_voc.wav -i ${1}.wav -filter_complex "
[0:a]
adeclip,
anlmdn=s=155,
compand=points=-80/-105|-62/-80|-15.4/-15.4|0/-12|20/-7,
speechnorm=e=8:r=0.0001:l=1,
ladspa=tap_autotalent:plugin=autotalent:
c=440 0.0 0.000 
1 0.5 1 0.5 1 0.5 1 0.5 1 0.5 1 0.5 
0.45 0.85 0.000 0 
0.000 0 
0.000 0.000 0.000 
0.15,
treble=g=10,
equalizer=f=150:width_type=h:width=100:g=3,
equalizer=f=800:width_type=h:width=100:g=-3,
equalizer=f=5000:width_type=h:width=100:g=3,
firequalizer=gain_entry='entry(250,-5);entry(4000,3)',
firequalizer=gain_entry='entry(-10,0);entry(10,2)',
aecho=0.8:0.9:99:0.2,

loudnorm=I=-16:LRA=11:TP=-1.5:print_format=summary,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[enhanced];
[1:a]
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16,
loudnorm=I=-16:LRA=11:TP=-1.5:print_format=summary[audio];
[audio][enhanced]amix=inputs=2:weights=0.5|0.5;
" -ar 44100 ${1}_go.wav && mplayer ${1}_go.wav;
