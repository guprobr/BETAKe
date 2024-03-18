#!/bin/bash

cd "${3}";
echo $( pwd );

echo -e "\e[93mUnload existing modules and restart PulseAudio\e[0m"
pactl unload-module module-ladspa-sink
pactl unload-module module-loopback
pactl unload-module module-echo-cancel
echo -e "\e[91mERRORS reported above HERE ARE NORMAL. restarting audio server now:\e[0m"
killall -HUP pipewire-pulse

# Load configuration variables
SINKA="beta_loopy";
SINKB="beta_kombo";
SINKC="beta_recz";

echo -e "\e[93m*HOUSEKEEPING SOUND SERVERS*\e[0m";
echo "** dando uma enxugada nos processos de audio.";
sleep 1
echo -n .
sleep 1;
echo -n .
echo -e "\e[93mINIT MIC\"SINK A\"\e[0m";
echo -e "\e[93mLoading module-remap-source for microphone sink\e[0m";
pactl load-module module-remap-source source_name=${SINKA} master=$(pactl list short sources | grep alsa_input | head -n1 | \awk '{ print $2 }');

# Load the echo cancellation module to cancel echo from the loopback
echo -e "\e[93mLoad module-echo-cancel\e[0m";
pactl load-module module-echo-cancel sink_name=echo-cancell master=${SINKA} \
        aec_method=webrtc aec_args="analog_gain_control=0 digital_gain_control=0";

#Load Ladspa effects
echo -e "\e[93mLoad module-ladspa-sink for pitch\e[0m"
pactl load-module module-ladspa-sink sink_name=${SINKB} plugin="tap_pitch" label=tap_pitch control="2,1,3,1,3" master=echo-cancell;
#echo -e "\e[93mLoad module-ladspa-sink for autotalent\e[0m"
#pactl load-module module-ladspa-sink sink_name=ladspa_talent plugin="tap_autotalent" label=autotalent master=ladspa_pitch;
#echo -e "\e[93mLoad module-ladspa-sink for declipper\e[0m"
#pactl load-module module-ladspa-sink sink_name=${SINKB} plugin="declip_1195" label=declip master=ladspa_pitch;

sleep 1
echo -n .
sleep 1;
echo -n .
echo "Ativando monitor do microfone";
pactl load-module module-loopback master=${SINKB};
echo -e "\e[91m[VOCÊ] deve Ajustar volume do mic ...\e[0m"
echo -e "\e[92mStarting to download lyrics-video and record audio\e[0m"; 
##################################
# PREPARE to Record the audio with effects applied
rm -rf playz/${1}_playback*;

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
		echo -e "\e[90mPREPARE-SE PARA CANTAR EM BREVE\e[0m"
		echo -e "\e[93m....\e[0m"
		echo "\e[90mPREPARE-se *5sec* para cantar!\e[0m";
			sleep 3;
			echo ...2;
			sleep 1;
			echo ...1;
			sleep 1;
		aplay "${3}research.wav";
		echo -e "\e[93mSING!--------------------------\e[0m"
		echo -e "\e[93m[FFMPEG] Video and audio Recording with effects applied...\e[0m"
			
			
			# Lauch vocal recorder via SoX	
			parec --device=${SINKB} | sox -V5 -t raw -r 48000 -b 16 -c 2  -e signed-integer -  \
				-t wav -r 48000 -b 16 -c 2 -e signed-integer "${3}recz/${1}_voc.wav" \
   									 dither -s &

#LAUNCH VIDEO RECORDER too
		ffmpeg -hide_banner  -loglevel info  -y -f v4l2 -input_format $( ffmpeg -loglevel quiet -hide_banner -formats \
			| grep -i $( v4l2-ctl --list-formats | egrep '\[[0-9]*\]' | \
			awk '{ print substr($2, 2, 3)}' | head -n1 ) | grep DE | \
			awk '{print $2}' | head -n1	) \
				 	-i /dev/video0 \
    							-strict experimental \
				-t ${PLAYBETA_LENGTH} -b:v 900k "${3}recz/${1}_voc.avi" | awk '{ print $7 }' | tail -n1  &
		
		###### prefer to use overlay for previeeew
		##ffplay -hide_banner -loglevel quiet ${3}recz/${1}_voc.avi &
		echo -e "\e[90mLaunch lyrics video\e[0m"
		ffplay -loglevel quiet -hide_banner -volume 15 -t ${PLAYBETA_LENGTH} ${3}"${BETA_PLAYFILE}" 		
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
killall -9 ffplay;
######################### trigger post processing
echo -e "\e[91mTRIGGER --- post-processing\e[0m";
${3}betaKE.sh "${1}" "${2}" "${3}";

# 2024 by gu.pro.br