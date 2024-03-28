#!/bin/bash

OUT_FILE=./outputs/BETAKE_beta.mp4;
OUT_VIDEO=./outputs/BETAKE_out.mp4;
OUT_VOCAL=./outputs/BETAKE_out.wav;
PLAYBACK_BETA=./recordings/BETAKE_playback.mp4;
PLAYBACK_LEN=$( echo "scale=0; $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${PLAYBACK_BETA}")/1" | bc ); 
diff_ss=0;
LC_ALL=C


ffmpeg -y -hide_banner -loglevel info  \
    -ss "$( printf "%0.4f" "$( echo "scale=4;  ${diff_ss}  " | bc )" )"  -i "${OUT_VIDEO}" \
    -ss "$( printf "%0.4f" "$( echo "scale=4;  ${diff_ss}  " | bc )" )" -i "${PLAYBACK_BETA}" \
                                                                                 -i "${OUT_VOCAL}" \
            -filter_complex "
[2:a]
    compensationdelay,alimiter,speechnorm,acompressor,
    ladspa=tap_pitch:plugin=tap_pitch:c=0.5 90 -20 16,
    ladspa=tap_autotalent:plugin=autotalent:c=440 0.00 0.0000 0 0 0 0 0 0 0 0 0 0 0 0 1.00 1.00 0 0 0 0.000 0.000 0.000 0 0 000.0 1.00,
    aecho=0.8:0.7:99:0.21,
    aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16
    [vocals];

    [1:a]dynaudnorm,volume=volume=0.55,
    aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[playback];

    [playback][vocals]amix=inputs=2;

      [1:v]scale=s=640x360[v1];
        gradients=n=8:type=spiral:s=640x360,format=rgba[vscope];
        [0:v]scale=s=640x360[v0]; 
        [v1][vscope]xstack,scale=s=640x360[badcoffee];
        [v0][badcoffee]vstack;" \
            -t "${PLAYBACK_LEN}" \
     -c:v libx264 -movflags faststart -s 1280x720 \
       -c:a aac  -ar 44100  \
         "${OUT_FILE}" 



exit