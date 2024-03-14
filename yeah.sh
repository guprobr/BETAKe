#!/bin/bash

# Introducing BETAKê v2.0 main feature: live-processing!

pactl unload-module module-ladspa-sink
pactl unload-module module-loopback
pactl unload-module module-echo-cancel

SINKA="echo-cancel-sink"; SRC_MASTER="alsa_input.usb-C-Media_Electronics_Inc._USB_PnP_Sound_Device-00.mono-fallback"; #adjust according to your cfg ( pactl list sources )

echo module-echo-cancel;
pactl load-module module-echo-cancel source_master=${SRC_MASTER} aec_method=webrtc;

echo tap_autotalent;
pactl load-module module-ladspa-sink sink_name=ladspa_talent plugin="tap_autotalent" control="440,1.6726875,0.0003,0,0,0,0,0,0,0,0,0,0,0,0,0.25,1.00,0,0,0,0.33825,1.000,1.000,0,0,0.0,0.15" label=autotalent;
pactl move-sink-input  $( pactl list sink-inputs | grep ladspa_talent -B25 | grep Sink\ Input | awk '{ print $3 }' | sed 's/#//g' )  ${SINKA};

echo DYNAMICS
pactl load-module module-ladspa-sink sink_name=ladspa_dyna label=tap_dynamics_m plugin=tap_dynamics_m control=4,700,15,15,13
pactl move-sink-input  $( pactl list sink-inputs | grep ladspa_dyna -B25 | grep Sink\ Input | awk '{ print $3 }' | sed 's/#//g' )  ${SINKA};

echo tap_pitch;
pactl load-module module-ladspa-sink sink_name=ladspa_pitch plugin="tap_pitch" label=tap_pitch control="0,0,0,0,0";
pactl move-sink-input  $( pactl list sink-inputs | grep ladspa_pitch -B25 | grep Sink\ Input | awk '{ print $3 }' | sed 's/#//g' )  ${SINKA};

echo fastLookaheadLimiter;
pactl load-module module-ladspa-sink sink_name=ladspa_limiter plugin="fast_lookahead_limiter_1913" label=fastLookaheadLimiter;
pactl move-sink-input  $( pactl list sink-inputs | grep ladspa_limiter -B25 | grep Sink\ Input | awk '{ print $3 }' | sed 's/#//g' )  ${SINKA};

echo EQUALIZER
pactl load-module module-ladspa-sink sink_name=ladspa_equalize label=tap_equalizer plugin=tap_eq control=-6,-6,-3,0,0,0,0,0,100,200,400,1000,3000,6000,12000,15000;
pactl move-sink-input  $( pactl list sink-inputs | grep ladspa_equalize -B25 | grep Sink\ Input | awk '{ print $3 }' | sed 's/#//g' )  ${SINKA};


echo module-declipper;
pactl load-module module-ladspa-sink sink_name=ladspa_declipper plugin="declip_1195" label=declip;
pactl move-sink-input  $( pactl list sink-inputs | grep ladspa_declipper -B25 | grep Sink\ Input | awk '{ print $3 }' | sed 's/#//g' )  ${SINKA};

#pactl set-default-sink ladspa_sink;
#audacity ${1}; #if u feel like editing not recording one-shot

pactl load-module module-loopback;

aplay ${1}.wav &
sox  -d ${1}_voc.wav
./go.sh "${1}" "${2}" "${3}" "${4}"
