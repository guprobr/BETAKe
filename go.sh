#!/bin/bash

pactl unload-module module-loopback;
pactl unload-module ladspa-sink;

ffmpeg -hide_banner   -i ${1}_voc.wav -i ${1}.wav -filter_complex "\

[0:a]adeclip,\
anlmdn=s=1000,\
dynaudnorm,\

ladspa=tap_autotalent:plugin=autotalent:\
c=440 0.0 0.000 \
0 0 0 0 0 0 0 0 0 0 0 0 \
1.00 1.000 0.000 0 \
0.000 0 \
1.000 1.000 0.000 \
0.15,\

compand=attacks=0:points=-80/-80|-12.4/-12.4|-6/-8|0/-6.8|20/-2.8,\
aecho=0.8:0.9:75:0.255,\
loudnorm=I=-16:LRA=11:TP=-1.5:print_format=summary,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,\
aresample=resampler=soxr:osf=s16[enhanced];\

[1:a]loudnorm=I=-16:LRA=11:TP=-1.5:print_format=summary,\
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,\
aresample=resampler=soxr:osf=s16[audio];\

[audio][enhanced]amix=inputs=2:weights=0.4|0.6;\
" ${1}_go.wav -y;


#lv2=p='urn\\:jeremy.salwen\\:plugins\\:talentedhack':c=mix=1.00|\
#voiced_threshold=1.00|pitchpull_amount=0.0|pitchsmooth_amount=1.00|\
#mpm_k=1.0|\
#da=0|daa=0|db=0|dc=0|dcc=0|dd=0|ddd=0|de=0|df=0|dff=0|dg=0|dgg=0|\
#oa=0|oaa=0|ob=0|oc=0|occ=0|od=0|odd=0|oe=0|of=0|off=0|og=0|ogg=0|\
#lfo_quant=5.412|lfo_amp=0.0,\

echo  "PLAY!";
mplayer ${1}_go.wav;

