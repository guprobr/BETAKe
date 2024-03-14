#!/bin/bash

pactl unload-module module-ladspa-sink
pactl unload-module module-loopback
pactl unload-module module-echo-cancel

#Now on v2.0 live-processing for Autotalent,
#we just have to enhance already pitch corrected vocal with effects
#then MASTERIZE for streaming both playback and enhanced vocals, mixing both
#
ffmpeg -y -hide_banner -i ${1}_voc.wav -i ${1}.wav -filter_complex "
[0:a]
adeclip,
anlmdn=s=13,
afftdn,
treble=g=1,
equalizer=f=150:width_type=h:width=100:g=3,
equalizer=f=800:width_type=h:width=100:g=-3,
equalizer=f=5000:width_type=h:width=100:g=3,
firequalizer=gain_entry='entry(250,-5);entry(4000,3)',
firequalizer=gain_entry='entry(-10,0);entry(10,2)',
aecho=0.8:0.7:100:0.2
[voc_enhanced];

[voc_enhanced]
loudnorm=I=-16:LRA=11:TP=-1.5,volume=volume=4dB,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[voc_master];

[1:a]
loudnorm=I=-16:LRA=11:TP=-1.5,volume=volume=3dB,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[play_master];

[play_master][voc_master]amix=inputs=2;

" -ar 44100 ${1}_go.wav && mplayer ${1}_go.wav; #then PLAY!

