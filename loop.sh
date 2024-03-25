#!/bin/bash

OUT_FILE=./outputs/BETAKE_beta.mp4;
OUT_VIDEO=./outputs/BETAKE_out.mp4;
OUT_VOCAL=./outputs/BETAKE_out.wav;
PLAYBACK_BETA=./recordings/BETAKE_playback.mp4;
PLAYBACK_LEN=$( cat ./outputs/BETAKE_dur.txt);
diff_ss=0;
LC_ALL=C


ffmpeg -y -hide_banner -loglevel info  \
    -ss "$( printf "%0.4f" "$( echo "scale=4; 0.4444 + ${diff_ss}  " | bc )" )"  -i "${OUT_VIDEO}" \
    -ss "$( printf "%0.4f" "$( echo "scale=4; 0.4444 + ${diff_ss}  " | bc )" )" -i "${PLAYBACK_BETA}" \
                                                                                 -i "${OUT_VOCAL}" \
            -filter_complex "
   [2:a]adeclip,afftdn,alimiter,speechnorm,acompressor, 
      ladspa=tap_pitch:plugin=tap_pitch:c=1.00669 21 -20 15,
      lv2=p='urn\\:jeremy.salwen\\:plugins\\:talentedhack':c=mix=1.0|voiced_threshold=0.99|pitchpull_amount=0.0|pitchsmooth_amount=1.00|mpm_k=1.0|da=0.000|daa=0.000|db=0.000|dc=0.000|dcc=0.000|dd=0.000|ddd=0.000|de=0.000|df=0.000|dff=0.000|dg=0.000|dgg=0.000|oa=0.000|oaa=0.000|ob=0.000|oc=0.000|occ=0.000|od=0.000|odd=0.000|oe=0.000|of=0.000|off=0.000|og=0.000|ogg=0.000|lfo_quant=0.0|lfo_amp=0.0,
     aecho=0.98:0.84:69:0.45,adynamicequalizer,treble=g=5,
       aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16
    [vocals];

    [1:a]
    aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[playback];

    [playback][vocals]amix=inputs=2,stereowiden,
    aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
    aresample=resampler=soxr:precision=28;

        [1:v]scale=s=300x200[v1];
       gradients=n=7:type=circular:s=300x200,scale=s=300x200[spats];
        gradients=n=6:type=spiral:s=300x200[vscope];
        [spats][vscope]hstack=inputs=2[spatscope];
          [1:a]avectorscope,frei0r=dither,colorize=hue=$((RANDOM%361)):saturation=$(bc <<< "scale=2; $RANDOM/32767"):lightness=$(bc <<< "scale=2; $RANDOM/32767"),
          scale=s=300x200[frodo];
          [0:v]colorize=hue=$((RANDOM%361)):saturation=$(bc <<< "scale=2; $RANDOM/32767"):lightness=$(bc <<< "scale=2; $RANDOM/32767"),
          scale=s=1280x720[v0]; 
          [spatscope]scale=s=300x200[scopy];
          [v1][scopy]xstack=inputs=2[video_merge];
          [frodo][video_merge]xstack=inputs=2,scale=s=1280x720[badcoffee];
          
          [v0][badcoffee]vstack=inputs=2;" \
             -ar 48000 -t "${PLAYBACK_LEN}" \
     -c:v libx264 -movflags faststart -preset ultrafast  \
       -c:a aac \
       -s 1920x1080 "${OUT_FILE}" 


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

