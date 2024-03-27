#!/bin/bash

OUT_FILE=./outputs/BETAKE_beta.mp4;
OUT_VIDEO=./outputs/BETAKE_out.mp4;
OUT_VOCAL=./outputs/BETAKE_out.wav;
PLAYBACK_BETA=./recordings/BETAKE_playback.mp4;
PLAYBACK_LEN=$( cat ./outputs/BETAKE_dur.txt);
diff_ss=0;
LC_ALL=C


ffmpeg -y -hide_banner -loglevel info  \
    -ss "$( printf "%0.4f" "$( echo "scale=4; 1.8444 + ${diff_ss}  " | bc )" )"  -i "${OUT_VIDEO}" \
    -ss "$( printf "%0.4f" "$( echo "scale=4; 1.8444 + ${diff_ss}  " | bc )" )" -i "${PLAYBACK_BETA}" \
                                                                                 -i "${OUT_VOCAL}" \
            -filter_complex "
[2:a]
afftdn=nr=15,compensationdelay,alimiter,speechnorm,acompressor,
ladspa=tap_pitch:plugin=tap_pitch:c=0.5 90 -20 20,
ladspa=tap_autotalent:plugin=autotalent:c=440 1.6726875 0.0000 0 0 0 0 0 0 0 0 0 0 0 0 1.00 1.00 0 0 0 0.33825 0.000 0.000 0 0 000.0 0.33,
aecho=0.8:0.7:99:0.13,
aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
aresample=resampler=soxr:osf=s16
[vocals];

   [1:a]aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[playback];

   [playback][vocals]amix=inputs=2:weights=0.551|0.669;

     [1:v]scale=s=640x360[v1];
       gradients=n=7:type=circular:s=640x360,scale=s=640x360[spats];
        gradients=n=6:type=spiral:s=640x360[vscope];
        [spats][vscope]overlay=alpha=0.6[spatscope];
          [1:a]avectorscope=s=640x360[frodo];
     [0:v]colorize=hue=$((RANDOM%361)):saturation=$(bc <<< "scale=2; $RANDOM/32767"):lightness=$(bc <<< "scale=2; $RANDOM/32767"),
          scale=s=640x360[v0]; 
          [spatscope]scale=s=640x360[scopy];
          [v1][frodo]hstack,scale=s=640x360[video_merge];
          [scopy][video_merge]hstack,scale=s=640x360[badcoffee];
          
          [v0][badcoffee]vstack,scale=s=1280x720;" \
             -ar 44100 -t "${PLAYBACK_LEN}" \
     -c:v libx264 -movflags faststart  \
       -c:a aac \
         "${OUT_FILE}" 



exit
pactl unload-module module-loopback;
#########
	pactl load-module module-loopback \
		source="${SINKb}"  \
		latency_msec=200;


exit
#LADSPA_declip
echo -e "\e[97mLoad module-ladspa-sink for declipper\e[0m";
pactl load-module module-ladspa-sink \
				control="-1,1" \
                plugin="declip_1195" label=declip \
                sink_name="LADSPA_declip" \
                master="${SINKa}";

#LADSPA_rnnoise
echo -e "\e[96mLoad module-ladspa-sink for RNNOISE\e[0m"
pactl load-module module-ladspa-sink \
                        plugin="librnnoise_ladspa" label="noise_suppressor_mono" \
                        control="1,5,50,500,50,0,0" \
                        sink_name="LADSPA_noise" \
                        master="${SINKa}";

#LADSPA_pitch
echo -e "\e[95mLoad module-ladspa-sink for pitch\e[0m"; 
pactl load-module module-ladspa-sink \
                sink_name="${SINKb}" \
                master="LADSPA_noise" \
    plugin="tap_pitch" label=tap_pitch control="2.066996,44,-11,11,-1"; 

#LADSPA AUTOTALENT TAP
#echo -e "\e[94mAltoTalent©\e[0m";
#pactl load-module module-ladspa-sink plugin="tap_autotalent" label=autotalent \
#                sink_name="LADSPA_talent" \
#                master="LADSPA_pitch" \
#        control="480,0,0.0000,0,0,0,0,0,0,0,0,0,0,0,0,0.11,1.00,0,0,0,0,1.000,1.000,0,0,000.0,0.09696";

#LADSPA sc4
#echo -e "\e[93mSC4\e[0m";
#pactl load-module module-ladspa-sink plugin="sc4_1882" label=sc4 \
 #               sink_name="${SINKb}"   \
 #               master="LADSPA_talent";

