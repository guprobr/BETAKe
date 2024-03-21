#!/bin/bash

karaoke_name="$1"
video_url="$2"
betake_path="$3"

# Configuration
REC_DIR="$betake_path/recordings"   # Directory to store recordings
OUT_DIR="$betake_path/outputs"      # Directory to store output files


# Function to generate MP3 from MP4
generate_mp3() {
    local mp4_file="$1"
    local mp3_file="$2"
    ffmpeg -y -hide_banner -loglevel error -i "$mp4_file" -vn -acodec libmp3lame -q:a 4 "$mp3_file"
}

# Function to get the start time of a process in Unix epoch seconds with %s format
get_process_start_time() {
    local pid="$1"
    # Get the start time of the process in Unix epoch seconds
    local start_epoch_seconds=$(ps -o lstart= -D "%s" -p "$pid")
    echo "$start_epoch_seconds"
}

# Function to get the modification time of a file and convert it to Unix epoch seconds
get_file_modification_time() {
    local file="$1"
    # Get the modification time of the file
    local mod_time=$(stat -c %Y "$file")
    echo "$mod_times"
}

# Function to calculate time difference in seconds
time_diff_seconds() {
    local start_secs="$1"
    local end_secs="$2"
    echo -e "$(( (end_seconds - start_seconds) ))"
}

# Define log file path
#LOG_FILE="$betake_path/script.log"


echo -e "\e[93mUnload existing modules and restart PulseAudio\e[0m"
pactl unload-module module-ladspa-sink
pactl unload-module module-loopback
pactl unload-module module-echo-cancel
echo -e "\e[91mERRORS reported above HERE ARE NORMAL. restarting audio server now:\e[0m"
killall -HUP pipewire-pulse

# Load configuration variables

SINKA="beta_loopy"
SINKB="beta_kombo"
echo -e "\e[93m*HOUSEKEEPING SOUND SERVERS*\e[0m";
echo -e "** dando uma enxugada nos processos de audio.";
sleep 1
echo .
sleep 1;
echo .
echo -e "\e[91mINIT MIC\"SINK A\"\e[0m";
echo -e "\e[93mLoading module-remap-source for microphone sink\e[0m";
pactl load-module module-remap-source source_name=${SINKA} master="$(pactl list short sources | grep alsa_input | head -n1 | \awk '{ print $2 }')";

#Load Ladspa effects


#LADSPA_rnnoise
echo -e "\e[93mLoad module-ladspa-sink for RNNOISE\e[0m"
pactl load-module module-ladspa-sink sink_name=LADSPA_rnnoise plugin="librnnoise_ladspa" label=noise_suppressor_mono control="50,200,0" master=${SINKA};
#LADSPA_declip
echo -e "\e[93mLoad module-ladspa-sink for declipper\e[0m"
pactl load-module module-ladspa-sink sink_name="LADSPA_declip" plugin="declip_1195" label=declip control="60,75" master=LADSPA_rnnoise;
#LADSPA_pitch
echo -e "\e[93mLoad module-ladspa-sink for pitch\e[0m"
pactl load-module module-ladspa-sink sink_name=LADSPA_pitch plugin="tap_pitch" label=tap_pitch control="0,0,0,0,0" master=LADSPA_declip;

#"Load the echo cancellation module to cancel echo";

#echo-cancell
echo -e "\e[93mLoad module-echo-cancel\e[0m";
pactl load-module module-echo-cancel sink_name="${SINKB}" master="LADSPA_pitch" \
    aec_method=webrtc aec_args="analog_gain_control=1 digital_gain_control=1";


echo -e "\e[93maAjustar vol do microfone\e[0m";
pactl set-source-volume "${SINKA}" 55%
echo -e "\e[92maAtivando monitor do microfone\e[0m";
##pactl load-module module-loopback source=${SINKB} sink="$( pactl list sinks short | grep output | head -n1 | awk '{ print $2 }' )"

echo -e "\e[95mDOWNLOAD video with [yt-dl]";
# Load the video title
PLAYBACK_TITLE="$(yt-dlp --get-title "${video_url}")"
rm -rf  "${REC_DIR}/${karaoke_name}"_playback.*;


# Download the video
yt-dlp "${video_url}" -o "${REC_DIR}/${karaoke_name}_playback.%(ext)s" --embed-subs --progress
BETA_PLAYFILE="$(ls "${REC_DIR}/${karaoke_name}_playback."*)"
PLAYBACK_LENGTH=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${BETA_PLAYFILE}")
aplay research.wav;


# Display message to start recording
zenity --question --text="Press OK to start: \"${PLAYBACK_TITLE}\" - duration: \"${PLAYBACK_LENGTH}\" " --title="BETAKe Recording Prompt" --default-cancel --width=200 --height=100
if [ $? = 1 ]; then
    echo "Recording canceled.";
    exit;
fi



# Recording and Post-production
OUTFILE="${OUT_DIR}/${karaoke_name}_voc.avi"

	
		echo -e "\e[93mSING!--------------------------\e[0m"
		echo -e "\e[92m[FFMPEG][SoX] Video and audio Recording with effects applied...\e[0m"
	
	#Launch VIDEO RECORDER v4l2
    
        #query webcam video format
        video_fmt="$( ffmpeg -loglevel quiet -hide_banner -formats \
			| grep -i "$( v4l2-ctl --list-formats | grep -E '\[[0-9]*\]' | \
			awk '{ print substr($2, 2, 3)}' | head -n1 )" | grep DE | \
			awk '{print $2}' | head -n1	)";

	#LAUNCH VIDEO RECORDER too
		ffmpeg -hide_banner  -loglevel quiet  -y -f v4l2 -input_format "${video_fmt}" \
				 	-i /dev/video0 \
    							-strict experimental \
				-t "${PLAYBACK_LENGTH}" -b:v 900k  "${OUTFILE}" &
                                    
	  
    #Launch AUDIO recorder SOX	
	echo -e "\e[91m..Launch SoX to record VOCALSs\e[0m"
		parec --device=${SINKB} --latency=13 | sox -V3 -t raw -r 44100 -b 16 -c 2 -e signed-integer - \
                                   -t wav -r 44100 -b 16 -c 2 -e signed-integer "${OUT_DIR}/${karaoke_name}_voc.wav" \
                                                             dither -s -f improved-e-weighted -p 16 \
															 				                        &

    echo -e "\e[99mLaunch lyrics video\e[0m"
	ffplay \
			-loglevel info -hide_banner -af "volume=0.5" "${BETA_PLAYFILE}" &
# this will Start playback of BETA_PLAYFILE in background and get start time
# Get the start time of the process
    ffplay_pid=$!;    

    echo -e "\e[95m..Acquire PLAYBACK process PID _ start_time to sync mechanism...\e[0m"
    proc_time=$(get_process_start_time $ffplay_pid); 
    # try to fix echo cancel bug
    ffplay -af "volume=2.5" -hide_banner -loglevel quiet -f pulse -i ${SINKB} research.wav &


# Initialize karaoke_duration variable
export cronos_play=1;
export LC_ALL=C;
rm -rf "${OUT_DIR}/${karaoke_name}_dur.txt";
while [ "$(printf "%.0f" "${cronos_play}")" -le "$(printf "%.0f" "${PLAYBACK_LENGTH}")" ]; do
    if [ ! -f "${OUT_DIR}/${karaoke_name}_dur.txt" ]; then
        wmctrl -R "BETAKe Recording" -b add,above;
    fi
    sleep 0.1
    cronos_play="$(echo "scale=4;  ${cronos_play} + 0.1 "| bc)";
    percent_play="$(echo "scale=4; ${cronos_play} * 100 / ${PLAYBACK_LENGTH} "  | bc)";
    echo "${cronos_play}" > "${OUT_DIR}/${karaoke_name}_dur.txt";
    echo "$( printf "%.0f" "${percent_play}" )"
done | zenity --progress --text="Press OK to STOP recording " \
--title="BETAKe Recording" --width=600 --height=300 --percentage=0

# Check if the progress dialog was canceled/completed
if [ $? = 1 ]; then
    echo "Recording canceled.";
else
    echo "Progress completed.";
fi

# Output the final value of karaoke_duration
cronos_play=$( cat "${OUT_DIR}/${karaoke_name}_dur.txt" );
echo "Calculated Karaoke duration: $cronos_play";

## when prompt window close, stop all recordings 
    
    sleep 1;
    
            killall -TERM ffmpeg;
            killall -HUP v4l2-ctl;
            killall -SIGINT sox;
            killall -9 ffplay;
            echo -e "\e[93mRecording finished\e[0m"
   
echo -e "\e[95mWhen recording finishes, get difference in secs to sync\e[0m"

# Get the duration of recording VERSUS duration of _voc.wav recorded.
export LC_ALL=C;

### organize vars related to sync: play = calculated time voc = actual size of recording
# we will have _time vars for integer versions, _float for the entire floating point value, and _dec for only the decimal part :D
    cronos_rec="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${OUT_DIR}/${karaoke_name}_voc.wav" )";
    

    echo "${cronos_play} - play";
    echo "${cronos_rec} - voc rec";
    diff_ss="$(echo "scale=4; ${cronos_rec} - ${cronos_play}" | bc)"; 
    echo -e "\e[91mFinal Time difference in seconds: $diff_ss\e[0m";

## Begin post-processing -- tried to do processing while recording, it worked very fast, but less quality.
echo -e "post-processing";
 echo -e "\e[90mrendering audio mix\e[0m";


ffmpeg -y -hide_banner -loglevel info   \
-ss $diff_ss    -i "${BETA_PLAYFILE}"           \
                -i "${OUT_DIR}/${karaoke_name}_voc.wav"  \
        -filter_complex "
                [1:a]adeclip,afftdn,alimiter,speechnorm,
                pan=stereo|c0=c0|c1=c0,acompressor,
                ladspa=tap_autotalent:plugin=autotalent:c=480 0 0.0000 0 0 0 0 0 0 0 0 0 0 0 0 1.00 1.00 0 0 0 0 1.000 1.000 0 0 000.0 0.045,
                stereowiden,adynamicequalizer,aexciter,treble=g=5,

                loudnorm=I=-16:LRA=11:TP=-1.5,
                aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
                aresample=resampler=soxr:osf=s16[voc_master];

                [0:a]loudnorm=I=-16:LRA=11:TP=-1.5,
                aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
                aresample=resampler=soxr:osf=s16[play_master];

                [play_master][voc_master]amix=inputs=2:weights=0.5|0.6;" \
        -acodec libmp3lame -ar 44100 -b:a 333k "${OUT_DIR}/${karaoke_name}_bk.mp3";

echo -e "\e[93mrendering video frames\e[0m"
## hear some mp3 while we werk yer vidz
ffplay  -af "volume=0.5" -window_title Preview_audio_MP3 -loglevel quiet -hide_banner "${OUT_DIR}/${karaoke_name}_bk.mp3" &

ffmpeg -y -loglevel info -hide_banner \
                -i "${OUT_DIR}/${karaoke_name}_bk.mp3" \
-ss $diff_ss    -i "${BETA_PLAYFILE}" \
                -i "${OUTFILE}" \
            -filter_complex "
         [1:v]scale=s=1920x1080[v1];
         life=s=800x600[spats];
         [1:a]avectorscope=m=polar:s=800x600[vscope];
          [2:v]scale=s=800x600[v0]; 
          [vscope][v0]hstack=inputs=2,scale=s=800x600[video_merge];
          [spats][video_merge]vstack=inputs=2,format=rgba,colorchannelmixer=aa=0.34,scale=s=1920x1080[waveform];
          [v1][waveform]overlay=10:10:enable='gte(t,0)',format=rgba,scale=s=1920x1080;" \
                                -strict experimental  -acodec libmp3lame -ar 48k -b:a 328k -map 0:a:0 -c:a copy \
                                                        -vcodec  h264 -b:v 900k -preset:v veryfast \
                                                          -t ${PLAYBACK_LENGTH}      "${OUT_DIR}/${karaoke_name}_bk.mp4" ;




# clean up

killall -9 ffplay;
killall -9 ffmpeg;
pactl unload-module module-loopback;

# Show the result using ffplay
ffplay -window_title -af "volume=0.5" "Resultado!" -loglevel quiet -hide_banner "${OUT_DIR}/${karaoke_name}_bk.mp4"

