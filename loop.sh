#!/bin/bash

OUT_FILE=./outputs/BETAKE_beta.mp4;
OUT_VIDEO=./outputs/BETAKE_out.mp4;
OUT_VOCAL=./outputs/BETAKE_out.wav;
PLAYBACK_BETA=./recordings/BETAKE_playback.mp4;
PLAYBACK_LEN=$( cat ./outputs/BETAKE_dur.txt);
diff_ss=0;

ffmpeg -y -hide_banner -loglevel info   \
    -ss "$( echo "scale=4; ${diff_ss} - 0.4444 " | bc | sed 's/-\./-0\./g')"    -i "${OUT_VIDEO}" \
    -ss "$( echo "scale=4; ${diff_ss} - 0.4444 " | bc | sed 's/-\./-0\./g')"    -i "${PLAYBACK_BETA}" \
                                                                                -i "${OUT_VOCAL}" \
          -filter_complex "
    [2:a] 
      ladspa=tap_pitch:plugin=tap_pitch:c=1.03699 21 -19 1, 
     ladspa=tap_autotalent:plugin=autotalent:c=440 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1.00 1.00 0 0 0 0 1.000 1.000 0 0 000.0 1.00,
     aecho=0.8:0.84:84:0.3,volume=volume=5dB
    [vocals];

    [1:a]volume=volume=3dB,
    aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[playback];

    [playback][vocals]amix=inputs=2:weights=0.3|0.6,
    aresample=resampler=soxr:precision=28;

        [1:v]scale=s=320x180,colorchannelmixer=aa=0.44[v1];
       gradients=n=7:type=circular:s=320x180[spats];
        gradients=n=5:type=spiral:s=320x180[vscope];
          [0:v]tile=color=0xFF8C00:init_padding=3:layout=2x2,scale=s=1280x720[v0]; 
          [vscope][v1]hstack=inputs=2,scale=s=320x180[video_merge];
          [video_merge][spats]vstack=inputs=2,colorchannelmixer=aa=0.77,tile=layout=3x1,scale=s=1280x720[badcoffee];
          [v0][badcoffee]overlay,scale=s=1920x1080;" \
             -ar 48000 -t "${PLAYBACK_LEN}" \
     -c:v libx265 -movflags faststart \
       -c:a pcm_s16le \
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

