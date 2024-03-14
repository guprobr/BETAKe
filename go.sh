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
anlmdn,
acompressor=threshold=-20dB:ratio=3:attack=50:release=100,
equalizer=f=150:width_type=h:width=100:g=3,
equalizer=f=800:width_type=h:width=100:g=-3,
equalizer=f=5000:width_type=h:width=100:g=3,
ladspa=sc4m_1916:plugin=sc4m:c=0 1.5 2 0 1 1 1,
treble=g=5,
afftdn,aecho=0.8:0.9:100:0.3
[voc_enhanced];

[voc_enhanced]
loudnorm=I=-16:LRA=11:TP=-1.5,volume=volume=5dB,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[voc_master];

[1:a]
loudnorm=I=-16:LRA=11:TP=-1.5,volume=volume=3dB,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[play_master];

[play_master][voc_master]amix=inputs=2:weights=0.5|0.6;

" -ar 44100 ${1}_go.wav && mplayer ${1}_go.wav; #then PLAY!

