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
    [2:a]anlmdn=s=25,afftdn=nr=25,ladspa=tap_pitch:plugin=tap_pitch:c=0.5 13 -20 19,acompressor,
    ladspa=tap_autotalent:plugin=autotalent:c=440 1.6726875 0.0000 0 0 0 0 0 0 0 0 0 0 0 0 1.000 1.00 0 0 0 0.33825 0.000 0.000 0 0 000.0 1.000,
    adynamicequalizer,aexciter,aecho=0.8:0.88:84:0.33,
    treble=g=5,deesser=i=0.64,loudnorm=I=-16:LRA=11:TP=-1.5,
    aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16
    [vocals];

   [1:a]loudnorm=I=-16:LRA=11:TP=-1.5,
    aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[playback];

   [playback][vocals]amix=inputs=2;

     [1:v]scale=s=300x200[v1];
       gradients=n=7:type=circular:s=300x200,scale=s=300x200[spats];
        gradients=n=6:type=spiral:s=300x200[vscope];
        [spats][vscope]overlay=alpha=0.6[spatscope];
          [1:a]avectorscope=s=300x200[frodo];
     [0:v]colorize=hue=$((RANDOM%361)):saturation=$(bc <<< "scale=2; $RANDOM/32767"):lightness=$(bc <<< "scale=2; $RANDOM/32767"),
          scale=s=1280x720[v0]; 
          [spatscope]scale=s=300x200[scopy];
          [v1][scopy]xstack=inputs=2[video_merge];
          [frodo][video_merge]xstack=inputs=2,scale=s=1280x720[badcoffee];
          
          [v0][badcoffee]vstack=inputs=2;" \
             -ar 48000 -t "${PLAYBACK_LEN}" \
     -c:v libx264 -movflags faststart -preset ultrafast  \
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

