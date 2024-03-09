#!/bin/bash


pactl unload-module module-loopback
pactl unload-module module-ladspa-sink

#echo B
#EQ and Dynamics
#pactl load-module module-ladspa-sink sink_name=ladspa_output label=tap_dynamics_m plugin=tap_dynamics_m control=4,700,15,15,13
#pactl load-module module-ladspa-sink sink_name=ladspa_output label=tap_equalizer plugin=tap_eq control=-6,-6,-3,0,0,0,0,0,100,200,400,1000,3000,6000,12000,15000; 
#echo C
#autotalent 
#pactl load-module module-ladspa-sink sink_name=ladspa_output master=alsa_output.pci-0000_00_1f.3.analog-stereo.monitor label=autotalent plugin=tap_autotalent control="444,-2,0.0069,1,1,1,1,1,1,1,1,1,1,1,1,1,1,-0.69,-3,0.13,0.21,1,1,0,0,0,0.44";

pactl load-module module-loopback latency_msec=13;

aplay ${1}.wav &
sox  -d ${1}_voc.wav
./go.sh "${1}" "${2}" "${3}" "${4}"
