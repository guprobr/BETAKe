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
echo "Test output or CTRL+c to abort..."
echo "Starting to record audio in 6sec"; 
sleep 6;
##################################
# Record the audio with effects applied
echo "Recording audio with effects applied..."
aplay ${1}.wav &  # Start playback
parec --device=${SINKB} | sox -t raw -r 44100 -b 16 -c 2 -e signed-integer - -t wav ${1}_voc.wav; 
##################################

# Unload existing modules and restart PulseAudio
pactl unload-module module-ladspa-sink
pactl unload-module module-loopback
pactl unload-module module-echo-cancel
killall -HUP pipewire-pulse
## kill playback if it is playing
killall -9 aplay

######################### trigger post processing
./betaKE.sh ${1} ${2}

# 2024 by gu.pro.br
