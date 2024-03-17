#!/bin/bash

cd "${3}";
echo $( pwd );

echo -e "\e[93mUnload existing modules and restart PulseAudio\e[0m"
pactl unload-module module-ladspa-sink
pactl unload-module module-loopback
pactl unload-module module-echo-cancel
echo -e "\e[91mERRORS HERE ARE NORMAL. restart audio server now:\e[0m"
killall -HUP pipewire-pulse

# Load configuration variables
SINKA="beta_loopy";
SINKB="beta_kombo";
SINKC="beta_recz";

echo -e "\e[93m*HOUSEKEEPING SOUND SERVERS*\e[0m";
echo "**";
echo -e "\e[93mINIT MICROPHONE INTO SINK \"A\"\e[0m"
#echo load-module module-alsa-source
#pactl load-module module-alsa-source device=$(pactl list short sources | grep alsa_input | head -n1 | awk '{ print $2 }') sink_name=${SINKA}
echo -e "\e[93mLoading module-remap-source for microphone sink\e[0m"
pactl load-module module-remap-source source_name=${SINKA} master=$(pactl list short sources | grep alsa_input | head -n1 | awk '{ print $2 }')

# Load Ladspa effects
echo -e "\e[93mLoad module-ladspa-sink for declipper\e[0m"
pactl load-module module-ladspa-sink sink_name=ladspa_declipper plugin="declip_1195" label=declip master=${SINKA};
echo -e "\e[93mLoad module-ladspa-sink for pitch\e[0m"
pactl load-module module-ladspa-sink sink_name=ladspa_pitch plugin="tap_pitch" label=tap_pitch control="0,0,0,-12,-12" master=ladspa_declipper;

# Load the echo cancellation module to cancel echo from the loopback
echo -e "\e[93mLoad module-echo-cancel\e[0m"
pactl load-module module-echo-cancel sink_name=echoe master=ladspa_pitch \
        aec_method=webrtc aec_args="analog_gain_control=1 digital_gain_control=1";

#echo -e "\e[93mLoad module-ladspa-sink for autotalent\e[0m"
#pactl load-module module-ladspa-sink sink_name=ladspa_talent plugin="tap_autotalent" control="440,1.6726875,0.003,0,0,0,0,0,0,0,0,0,0,0,0,1.00,1.00,0,0,0,0.33825,1.000,1.000,1,1,0.0,1.00" label=autotalent master=ladspa_pitch;
#echo -e "\e[93mLoad module-ladspa-sink for dynamics\e[0m"
#pactl load-module module-ladspa-sink sink_name=${SINKB} label=tap_dynamics_m plugin=tap_dynamics_m control=4,700,15,15,13 master=ladspa_pitch;

pactl load-module module-loopback;

echo "**";
echo "**";
echo -e "\e[92mNOW Test output or CTRL+c to abort...\e[0m"
echo -e "\e[92mStarting to donwload lyrics video and record audio\e[0m"; 
##################################
# PREPARE to Record the audio with effects applied
rm -rf playz/${1}_playback*;

####pavumeter --record --sync &
if [ "${2}" != "" ];
then
	echo -e "\e[93m[YT-DL] Received apparently a URL, gonna try get lyrics video..\e[0m"; 
	PLAYBETA_TITLE="$( yt-dlp --get-title "${2}" )";
	echo  ${PLAYBETA_TITLE};
	#Got title, gonna get video :D
	yt-dlp "${2}" -o ${3}playz/${1}_playback \
	--embed-subs --progress;
	if [ $? -eq 0 ]; then
		BETA_PLAYFILE="$( ls -1 playz/${1}_playback.* | head -n1 )"
		PLAYBETA_LENGTH=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ${3}"${BETA_PLAYFILE}")
		echo ${PLAYBETA_LENGTH};
		### gmbiarra de usar tudo AVI
		echo -e "\e[93m[FFMPEG] to speed up ffmpeg postprocessing, go for AVI\e[0m"
		echo "\e[93m...\e[0m"
		echo -e "\e[90mAGUARDE PARA CANTAR EM BREVE\e[0m"
		echo -e "\e[93m....\e[0m"
		echo "PREPARE-se para cantar!";
		echo -e "\e[93m[VOCÊ] Ajustar volume do microfone e verificar imagem...\e[0m"

		ffmpeg -hide_banner -loglevel quiet -y -i ${3}"$BETA_PLAYFILE" ${3}"${BETA_PLAYFILE}.avi"
		aplay "${3}research.wav";
		echo -e "\e[93m[FFMPEG] Video and audio Recording with effects applied...\e[0m"
			# Lauch vocal recorder via SoX	
			parec --device=${SINKB} | sox -t raw -r 48000 -b 16 -c 2 \
				-e signed-integer - -t wav "${3}recz/${1}_voc.wav" \
									dither  &
		
		ffmpeg -hide_banner  -loglevel quiet  -y -f v4l2 -input_format $( ffmpeg -loglevel quiet -hide_banner -formats \
			| grep -i $( v4l2-ctl --list-formats | egrep '\[[0-9]*\]' | \
			awk '{ print substr($2, 2, 3)}' | head -n1 ) | grep DE | \
			awk '{print $2}' | head -n1	) \
				-ss 1s -i /dev/video0 \
    							-strict experimental \
				-t ${PLAYBETA_LENGTH} "${3}recz/${1}_voc.avi" &
		
		###### prefer to use overlay for previeeew
		##ffplay -hide_banner -loglevel quiet ${3}recz/${1}_voc.avi &
		echo -e "\e[93mLaunch lyrics video\e[0m"
		echo -e "\e[93mSING!\e[0m"
		ffplay -loglevel quiet -hide_banner -volume 55 -t ${PLAYBETA_LENGTH} ${3}"${BETA_PLAYFILE}.avi" 		
	else
		echo -e "\e[91mFAILED LYRICS VIDEO.\e[0m"; 
		echo -e "\e[91mABORT\e[0m"; exit 1;
	fi
else
	echo -e "\e[91mINVALID URL --- no lyrics video\e[0m";
	echo -e "\e[91mABORT\e[0m"; exit 1;
fi


##################################
echo "\e[93mSTOP RECORDING after mplayer exits\e[0m"
# or if BETA_LENGTH reaches;
echo "\e[90msignal FFMpeg to interrupt rendering gracefully\e[0m";
sleep 7; 
killall -SIGINT sox;
killall -SIGINT ffmpeg;

#echo -e "\e[93mMerge webcam video with mic input\e[0m"
#ffmpeg -hide_banner \
#-i "${3}recz/${1}_voc.flac" -i "${3}recz/${1}_voc.avi" \
#
#								"${3}recz/${1}_vv.avi"; 
######################### trigger post processing
echo -e "\e[91mTRIGGER --- post-processing\e[0m";
${3}/betaKE.sh "${1}" "${2}" "${3}";

# 2024 by gu.pro.br