#!/bin/bash

# Unload existing modules and restart PulseAudio
pactl unload-module module-ladspa-sink
pactl unload-module module-loopback
pactl unload-module module-echo-cancel
killall -HUP pipewire-pulse

# Load configuration variables
SINKA="beta_loopy";
SINKB="beta_kombo";
SINKC="beta_recz";

# Load the null sink module to create a virtual sink named "loopback"
echo "**";
echo "**";
echo "Wait 3 seconds to initialize..."
sleep 3;

pactl load-module module-alsa-source device=$(pactl list short sources | grep alsa_input | head -n1 | awk '{ print $2 }') sink_name=${SINKA}

# Load the echo cancellation module to cancel echo from the loopback
echo "Load module-echo-cancel"
pactl load-module module-echo-cancel sink_name=echoe master=${SINKA} \
        aec_method=webrtc aec_args="analog_gain_control=1 digital_gain_control=1";
# Load Ladspa effects
echo "Load module-ladspa-sink for declipper"
pactl load-module module-ladspa-sink sink_name=ladspa_declipper plugin="declip_1195" label=declip master=echoe;
echo "Load module-ladspa-sink for pitch"
pactl load-module module-ladspa-sink sink_name=${SINKB} plugin="tap_pitch" label=tap_pitch control="0,0,0,-6,-6" master=ladspa_declipper;
### never sactiscatory made autotune to werk live-recording
#echo "Load module-ladspa-sink for autotalent"
#pactl load-module module-ladspa-sink sink_name=ladspa_talent plugin="tap_autotalent" control="440,1.6726875,0.003,0,0,0,0,0,0,0,0,0,0,0,0,1.00,1.00,0,0,0,0.33825,1.000,1.000,1,1,0.0,1.00" label=autotalent master=ladspa_pitch;
#echo "Load module-ladspa-sink for dynamics"
#pactl load-module module-ladspa-sink sink_name=ladspa_dyna label=tap_dynamics_m plugin=tap_dynamics_m control=4,700,15,15,13 master=ladspa_talent;
#echo "Load module-ladspa-sink for lookahead limiter"
#pactl load-module module-ladspa-sink sink_name=${SINKB} plugin="fast_lookahead_limiter_1913" label=fastLookaheadLimiter master=ladspa_dyna;

echo "sleep 1sec"; sleep 1;
pactl load-module module-loopback;

echo "**";
echo "**";
echo "NOW Test output or CTRL+c to abort..."
echo "Starting to donwload lyrics video and record audio"; 
##################################
# PREPARE to Record the audio with effects applied
PLAYBETA_LENGTH=$( mplayer -ao null -identify -frames 0 \
				${1}.wav 2>&1 \
| grep ID_LENGTH | cut -d= -f2 );

## quickly prepare a lyrics video - from YouTube

if [ "${2}" != "" ];
then
	echo "Received apparently a URL, gonna try get lyrics video.."; 
	PLAYBETA_TITLE="$( yt-dlp --get-title "${2}" )"; 
	#Got title, gonna get video :D
	yt-dlp "${2}" -o playz/${1}_playback \
	--embed-subs --progress;
	if [ $? -eq 0 ]; then
		BETA_PLAYFILE="$( ls -1 playz/${1}_playback.* | head -n1 )"
		ffmpeg -loglevel quiet -hide_banner -y -i "${BETA_PLAYFILE}" playz/"${1}.wav";
		echo "RECORDING!!!! Recording audio with effects applied..."
		parec --device=${SINKB} | sox -t raw -r 48000 -b 16 -c 1 \
		-e signed-integer - -t wav recz/"${1}_voc.wav" \
							dither trim 0 ${PLAYBETA_LENGTH} &
	       #Launch lyrics video
		ffplay -hide_banner "${BETA_PLAYFILE}"; 
		#SING!
	else
		echo "FAILED LYRICS VIDEO."; 
		echo ABORT; exit 1;
		#echo "will use existing ${1}.wav";
		#vlc -I ncurses playz/${1}.wav --sub-track 0 &
	fi
else
	echo "INVALID URL --- no lyrics video";
	echo ABORT; exit 1;
	#vlc -I ncurses playz/${1}.wav --sub-track 0 &
fi


##################################
###### STOP RECORDING after mplayer exits
# or if BETA_LENGTH reaches;
# signal sox to interrupt recording if necessary
killall -SIGINT sox;

### HOUSEKEEP
# rly termate useless process by now
killall -9 vlc;
killall -9 mplayer
killall -9 parec 
killall -9 ffmpeg


######################### trigger post processing
./betaKE.sh "${1}" "${BETA_PLAYFILE}" "${BETA_TITLE}"

# 2024 by gu.pro.br
