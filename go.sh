#!/bin/bash

pactl unload-module module-loopback;
pactl unload-module ladspa-sink;

ffmpeg -y -hide_banner -i ${1}_voc.wav -i ${1}.wav -filter_complex "
[0:a]
adeclip,
anlmdn=s=35,
compand=points=-80/-105|-62/-80|-15.4/-15.4|0/-12|20/-7,
speechnorm=e=8:r=0.0001:l=1,
ladspa=tap_autotalent:plugin=autotalent:
c=440 0.0 0.000 
1 0.5 1 0.5 1 0.5 1 0.5 1 0.5 1 0.5 
0.84 0.98 0.000 0 
0.000 0 
0.000 0.000 0.000 
0.25,
treble=g=5,
equalizer=f=150:width_type=h:width=100:g=3,
equalizer=f=800:width_type=h:width=100:g=-3,
equalizer=f=5000:width_type=h:width=100:g=3,
firequalizer=gain_entry='entry(250,-5);entry(4000,3)',
firequalizer=gain_entry='entry(-10,0);entry(10,2)',
ladspa=sc4_1882:plugin=sc4:c=0.5 50 100 -10 5 1 10,
loudnorm=I=-16:LRA=11:TP=-1.5:print_format=summary,
aecho=0.8:0.9:94:0.255,

aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[enhanced];
[1:a]
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16,
loudnorm=I=-16:LRA=11:TP=-1.5:print_format=summary[audio];
[audio][enhanced]amix=inputs=2:weights=0.4|0.8;
" -ar 44100 ${1}_go.wav && mplayer ${1}_go.wav;



#lv2=p='urn\\:jeremy.salwen\\:plugins\\:talentedhack':c=mix=1.00|\
#voiced_threshold=1.00|pitchpull_amount=0.0|pitchsmooth_amount=1.00|\
#mpm_k=1.0|\
#da=0|daa=0|db=0|dc=0|dcc=0|dd=0|ddd=0|de=0|df=0|dff=0|dg=0|dgg=0|\
#oa=0|oaa=0|ob=0|oc=0|occ=0|od=0|odd=0|oe=0|of=0|off=0|og=0|ogg=0|\
#lfo_quant=5.412|lfo_amp=0.0,\

echo  "PLAY!";
mplayer ${1}_go.wav;

