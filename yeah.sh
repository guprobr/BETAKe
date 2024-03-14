#!/bin/bash

# Introducing BETAKê v2.0 main feature: live-processing!

pactl unload-module module-ladspa-sink
pactl unload-module module-loopback
pactl unload-module module-echo-cancel

SINKA="echo-cancel-sink";

echo module-echo-cancel;
pactl load-module module-echo-cancel aec_method=webrtc;

echo tap_autotalent;
pactl load-module module-ladspa-sink sink_name=ladspa_talent plugin="tap_autotalent" control="440,1.6726875,0.0003,\
        0,0,0,0,0,0,0,0,0,0,0,0,\
        0.25,1.00,0,0,0,\
        0.33825,1.000,1.000,\
        0,0,0.0,0.15" label=autotalent;

        pactl move-sink-input  $( pactl list sink-inputs | grep ladspa_talent -B25 | grep Sink\ Input | awk '{ print $3 }' | sed 's/#//g' )  ${SINKA};

#pactl set-default-sink ladspa_sink;
#audacity ${1}; #if u feel like editing not recording one-shot

pactl load-module module-loopback;

aplay ${1}.wav &
sox  -d ${1}_voc.wav
./go.sh "${1}" "${2}" "${3}" "${4}"
