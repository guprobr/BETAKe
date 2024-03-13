#!/bin/bash

pactl unload-module module-loopback;
pactl unload-module ladspa-sink;

#provide preprocessing for Autotalent, 
#then, enhance pitch corrected vocal with effects
#then MASTERIZE for streaming both playback and enhanced vocals, mixing both
#
ffmpeg -y -hide_banner -i ${1}_voc.wav -i ${1}.wav -filter_complex "
[0:a]
adeclip,
anlmdn=s=69,
compand=points=-80/-105|-62/-80|-15.4/-15.4|0/-12|20/-7,
ladspa=tap_autotalent:plugin=autotalent:
c=440 1.6726875 0.03 0 0 0 0 0 0 0 0 0 0 0 0 1.00 1.00 0 0 0 0.33825 1.000 1.000 0 0 0.0 1.00,
afftdn,
treble=g=5,
equalizer=f=150:width_type=h:width=100:g=3,
equalizer=f=800:width_type=h:width=100:g=-3,      
equalizer=f=5000:width_type=h:width=100:g=3,      
firequalizer=gain_entry='entry(250,-5);entry(4000,3)',
firequalizer=gain_entry='entry(-10,0);entry(10,2)',
ladspa=fast_lookahead_limiter_1913:plugin=fastLookaheadLimiter:c=-3 -3 0.1,
ladspa=sc4_1882:plugin=sc4:c=0.5 50 100 -20 10 5 12,
aecho=0.8:0.7:84:0.2
[voc_enhanced];

[voc_enhanced]
loudnorm=I=-16:LRA=11:TP=-1.5,volume=volume=3dB,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[voc_master];

[1:a]
loudnorm=I=-16:LRA=11:TP=-1.5,volume=volume=4dB,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[play_master];

[play_master][voc_master]amix=inputs=2;

" -ar 44100 ${1}_go.wav && mplayer ${1}_go.wav; #then PLAY!

