#!/bin/bash
# by gu.pro.br 2024
# Nesse arquivo realizamos a fase automatica de pós-processamento,
# no diretporio ./outz serãogeradas uma MP3 do audio com os filtros e enhancements
# E uma MP4 psicodelica que combina visuaizadores sonoros, com a gravação da sua imagem cantando
# assim como projetado em alpha channel, o proprio video q vc escolheu para cantar.
# o programa é bem agressivo e nao pergunta, ja vai tocando as coisas qdo fica pronta

# é isso:q!
#pensei que tava no vim, to nesse vscode q soh confunde a cabeça  18/03/1984 v2.9

cd "${3}";
pwd;

echo '[betaKE.sh]'
echo -e "\e[90mclean the mess left by betaREC\e[0m"
                killall -HUP pipewire-pulse;
                pactl unload-module module-loopback;
                pactl unload-module module-echo-cancel;
                pactl unload-module module-ladspa-sink;

PLAYBETA_TITLE="$( yt-dlp --get-title "${2}" )"; 
BETA_PLAYFILE="$( ls -1 ${3}playz/${1}_playback.* | head -n1 )";
BETA_TITLE="${PLAYBETA_TITLE}";

if [ "${1}" == "" ]; then
        echo INFORMAR O PARAMETROS, nome_KARAOKE
else
        if [ "${PLAYBETA_TITLE}" == "" ]; then
                BETA_TITLE="${1}"
        fi
fi
##### v2.9 - ++ app e menos script, para todos poderem usar
#### v2.7 - now it grabs video from webcam
#### v2.5: current version
#Since v2.0 live-processing for Autotalent, never worked.
#we just have to enhance already pitch corrected vocal with effects     

#then MASTERIZE for streaming both playback and enhanced vocals, mixing both
PLAYBETA_LENGTH=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${3}recz/${1}_voc.avi" )
echo ${PLAYBETA_LENGTH}; echo ${BETA_TITLE}; echo "${BETA_PLAYFILE}";
#post-processing
echo "POST_PROCESSING____________________________________"
 echo -e "\e[90mrendering audio mix\e[0m"
ffmpeg -y -hide_banner -loglevel info  -ss 1.22 -i "${BETA_PLAYFILE}" -i "${3}recz/${1}_voc.wav" \
        -filter_complex "
[1:a]adeclip,afftdn,alimiter,speechnorm,acompressor,
ladspa=tap_autotalent:plugin=autotalent:c=440 0 0.0000 0 0 0 0 0 0 0 0 0 0 0 0 1.00 1.00 0 0 0 0 1.000 1.000 0 0 000.0 0.045,
pan=stereo|c0=c0|c1=c0,rubberband=pitch=0.96939,
compand=points=-80/-105|-62/-80|-15.4/-15.4|0/-12|20/-7,
aecho=0.9:0.84:71:0.22,
adynamicequalizer,aexciter,loudnorm=I=-16:LRA=11:TP=-1.5,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[voc_master];
[0:a]loudnorm=I=-16:LRA=11:TP=-1.5,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16[play_master];

[play_master][voc_master]amix=inputs=2:weights=0.4|0.7;" \
                -acodec libmp3lame -ar 48k -b:a 320k "${3}outz/${BETA_TITLE}_[BETAKe].mp3";

echo -e "\e[90mrendering video frames\e[0m"

## hear some mp3 while we werk yer vidz
ffplay -fs -loglevel quiet -hide_banner "${3}outz/${BETA_TITLE}_[BETAKe].mp3" &

ffmpeg -y -loglevel info -hide_banner \
        -i "${3}outz/${BETA_TITLE}_[BETAKe].mp3" \
        -ss 1.22 -i "${BETA_PLAYFILE}" \
        -ss 1.22 -i "${3}recz/${1}_voc.avi" \
        -filter_complex "
         [1:v]scale=s=1024x900[v1];
         [0:a]showspatial=s=300x200[spats];
         [1:a]avectorscope=m=polar:s=300x200[vscope];
          [2:v]scale=s=300x200[v0]; 
          [vscope][v0]hstack=inputs=2,scale=s=300x200[video_merge];
          [spats][video_merge]vstack=inputs=2,format=rgba,colorchannelmixer=aa=0.34,scale=s=1024x900[waveform];
          [v1][waveform]overlay=10:10:enable='gte(t,0)',format=rgba,scale=s=1920x1080;" \
                                -strict experimental  -acodec libmp3lame -ar 48k -b:a 320k -map 0:a:0 -c:a copy \
                                                        -vcodec  h264 -b:v 933k -preset:v veryfast \
                                                                "${3}outz/${BETA_TITLE}_[BETAKe].mp4" ;

killall -9 ffplay;

ffplay -fs -loglevel quiet -hide_banner "${3}outz/${BETA_TITLE}_[BETAKe].mp4";
# 2024 by gu.pro.br:weights=0.55|0.45,