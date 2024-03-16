#!/bin/bash

if [ "${1}" == "" ]; then
        echo INFORMAR DOIS PARAMETROS, nome_playback sem extensao WAV e TITULO mp3;
else
        if [ "${2}" == "" ]; then
                echo INFORMAR TITULO mp3 gerada;
        fi
fi

#### v2.5: current version
#Since v2.0 live-processing for Autotalent, never worked.
#we just have to enhance already pitch corrected vocal with effects
#then MASTERIZE for streaming both playback and enhanced vocals, mixing both
#
### RECORD (q) to quit

##### here i tried to record via ffmpeg, successfully, but same echo-cancel issue
#so we use sox again
# new output recording .wav will exist
#rm -rf recz/"${2} _ cover by Guzpido.wav" 
# Check if the output recording .wav exists, and wait until it does
#( while [ ! -f recz/"${2}_[BETAKE].mp4" ]; 
#       do 
#               sleep 0.1; 
#               echo -n '.'; 
#       done && aplay ${1}.wav ) & ### started playback. now user sings.
#-f pulse -i $( pactl list short sources | grep "${GOGOGO}" | head -n 1 | awk '{print $1}'  ) 
## trying to make it run on recording time

#post-processing
ffmpeg -y -hide_banner -i ${1}_voc.wav -i ${1}.wav -i tux.jpeg -filter_complex "
[0:a]
anlmdn=s=13,highpass=f=100,lowpass=f=15000,
ladspa=tap_autotalent:plugin=autotalent:c=440 1.6726875 0.0000 0 0 0 0 0 0 0 0 0 0 0 0 1.000 1.00 0 0 0 0.33825 1.000 1.000 0 1 000.0 1.000,
compand=points=-80/-105|-62/-80|-15.4/-15.4|0/-12|20/-7,
firequalizer=gain_entry='entry(250,-5);entry(4000,3)',
firequalizer=gain_entry='entry(-10,0);entry(10,2)',
aecho=0.8:0.7:111:0.13,
extrastereo=m=1.5,lowpass=3000,highpass=200,treble=g=5,
loudnorm=I=-16:LRA=11:TP=-1.5,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[voc_master];

[1:a]
loudnorm=I=-16:LRA=11:TP=-1.5,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[play_master];

[play_master][voc_master]amix=inputs=2:weights=0.4|0.6,
afade=t=in:st=0:d=2;" -ar 44100 -acodec aac -b:a 320k \
                                recz/"${2} _ cover by Guzpido.mp4"

### clean the mess
                killall -HUP pipewire-pulse;
                pactl unload-module module-loopback;
                pactl unload-module module-echo-cancel;
                pactl unload-module module-ladspa-sink;

echo "Sleep 2sec";
sleep 2;

mplayer recz/"${2}_[BETAKe]"; #then PLAY!

# 2024 by gu.pro.br
