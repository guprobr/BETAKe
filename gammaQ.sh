#!/bin/bash



karaoke_name="$1"
video_url="$2"
betake_path="$3"

if [ ${karaoke_name} == "" ]; then karaoke_name="BETA"; fi
if [ ${video_url} == "" ]; then video_url=" --simulate "; fi
if [ ${betake_path} == "" ]; then betake_path="./"; fi

# Configuration
REC_DIR="$betake_path/recordings"   # Directory to store recordings
OUT_DIR="$betake_path/outputs"      # Directory to store output files

    mkdir -p "$REC_DIR"; # It happened once, far far away from these lands,
    mkdir -p "$OUT_DIR"; # a very recent fact indeed, those directories being erased
                        # goddam!
reboot_pulse() {
    echo -e "\e[93mUnload existing modules and restart PulseAudio\e[0m";
    pactl unload-module module-ladspa-sink;
    pactl unload-module module-loopback;
    pactl unload-module module-echo-cancel;
    echo -e "\e[91mERRORS reported above HERE ARE NORMAL. It means already unloaded\e[0m"; 
    echo -ee "\e93m[[[[RESTARTING]]]]  audio server now:\e[0m";
    killall -HUP pipewire-pulse
    sleep 5; echo "please wait 5 secs";
}

reboot_pulse 'done';
#query webcam video format
whatsvideo_fmt() { "$( ffmpeg -loglevel quiet -hide_banner -formats \
			| grep -i "$( v4l2-ctl --list-formats | grep -E '\[[0-9]*\]' | \
			awk '{ print substr($2, 2, 3)}' | head -n1 )" | grep DE | \
			awk '{print $2}' | head -n1	)" 
}
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
LOG_FILE="$betake_path/script.log"


# Load configuration variables
SINKA="beta_loopy"
SINKB="beta_kombo"


echo -e "\e[93m*HOUSEKEEPING SOUND SERVERS*\e[0m";
echo -e "\e[91mINIT MIC\"SINK A\"\e[0m";
echo -e "\e[93mLoading module-remap-source for microphone sink\e[0m";
pactl load-module module-remap-source source_name="${SINKA}" source_master="$(pactl list short sources | grep alsa_input | head -n1 | \awk '{ print $2 }')";

#"Load the echo cancellation module to cancel echo";
#echo -e "\e[96mLoad module-echo-cancel\e[0m";
#pactl load-module module-echo-cancel sink_name="ECHO_cancel" master="${SINKA}" \
# aec_method=webrtc aec_args="analog_gain_control=0 digital_gain_control=1";
echo -e "\e[94mTAP PITCH\e[0m";
pactl load-module module-ladspa-sink sink_name="${SINKB}" plugin="tap_pitch" label="tap_pitch" control="8,77,3,5,0" master="${SINKA}";
#echo -e "\e[91mAltoTalent©\e[0m";
#pactl load-module module-ladspa-sink sink_name="LADSPA_autotalent" plugin="tap_autotalent" label=autotalent master="LADSPA_pitch" \
#        control="480,0,0.0000,0,0,0,0,0,0,0,0,0,0,0,0,1.00,1.00,0,0,0,0,1.000,1.000,0,0,000.0,1.000";
#echo -e "\e[97mFastLookaheadLimiter\e[0m";
#pactl load-module module-ladspa-sink sink_name="LADSPA_limit" plugin="fast_lookahead_limiter_1913" label=fastLookaheadLimiter master="LADSPA_autotalent";
#echo -e "\e[90mSC4\e[0m";
#pactl load-module module-ladspa-sink sink_name="${SINKB}" plugin="sc4_1882" label=sc4  master="TAP_PITCH";

echo -e "\e[91maAjustar vol dos headphones: USE HEADPHONES\e[0m";
pactl set-source-volume "${SINKA}" 44%
echo -e "\e[93maAjustar vol do microfone\e[0m";
pactl load-module module-loopback #latency_msec=1 #source="${SINKB}" sink="$( pactl list sinks short | grep output | head -n1 | awk '{ print $2 }' )";
#pavumeter ${SINKB} &
wmctrl -R "PulseAudio Volume Meter" -b add,above;



## iniciar preparo de adquirir playback e construir pipeline do gravador
PLAYBACK_BETA="${REC_DIR}/${karaoke_name}_playback.avi";
#remover playbacks antigos para nao dar problema em baixar novos
rm -rf "${REC_DIR}"/"${karaoke_name}"_playback.*;
# Load the video title
PLAYBACK_TITLE="$(yt-dlp --get-title "${video_url}")"
# Download the video
yt-dlp "${video_url}" -o "${REC_DIR}/${karaoke_name}_playback.%(ext)s" --format 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --console-title --embed-subs --progress --no-continue --force-overwrites --default-search "ytsearch: karaoke Lyrics --match-filter duration < 300"; 


# Display message to start converting
export LC_ALL=C;
zenity --question --text="Going to convert: \"${PLAYBACK_TITLE}\" - duration: \"$(printf "%.0f" "${PLAYBACK_LENGTH}")\", do you want this playback? " --title="BETAKe Recording Prompt" --default-cancel --width=200 --height=100
if [ $? == 1 ]; then
    echo "Recording canceled.";
    reboot_pulse true;

    wmctrl -c 'BETAKê CMD prompt';
    exit;
fi

# Find the first file with either .mp4 or .webm extension
filename=$(find "$REC_DIR" \( -name "${karaoke_name}_playback.mkv" -o -name "${karaoke_name}_playback.mp4" -o -name "${karaoke_name}_playback.webm" \) -print -quit)
# Check if a file was found
if [ -n "$filename" ]; then
    echo "Using file: $filename"
   #convertemos para avi, pois precisamos usar AVI por enquanto, outros codecs dão bug
   ffmpeg -y -hide_banner -loglevel info "${filename}" "${PLAYBACK_BETA}";
   echo -e "\e[91mPlayback convertido para AVI\e[0m";
else
    echo "No suitable playback file found."
        reboot_pulse true;
    exit
fi

if [ ! -n "${PLAYBACK_BETA}" ]; then  
     echo "No suitable playback file converted to AVI.";
         reboot_pulse true;
     exit;
fi

PLAYBACK_LENGTH=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${PLAYBACK_BETA}")
echo -e "\e[91mAll setup to sing!";
aplay research.wav;
# Display message to start recording
export LC_ALL=C;
zenity --question --text="Read to record: \"${PLAYBACK_TITLE}\" - duration: \"$(printf "%.0f" "${PLAYBACK_LENGTH}")\", do you want this playback? " --title="BETAKe Recording Prompt" --default-cancel --width=200 --height=100
if [ $? == 1 ]; then
    echo "Recording canceled.";
        reboot_pulse true;
    wmctrl -c 'BETAKê CMD prompt';
    exit;
fi

# Recording and Post-production
OUTFILE="${OUT_DIR}"/"${karaoke_name}"_out.avi;
	
echo -e "\e[93mSING!--------------------------\e[0m";
		echo -e "\e[99mLaunch lyrics video\e[0m";

	            ffplay \
			        -window_title "SING" -loglevel info -hide_banner -af "volume=0.35" "${PLAYBACK_BETA}" &
                ffplay_pid=$!;
                    wmctrl -R "SING" -b add,above;
                     epoch_ffplay=$( get_process_start_time "${ffplay_pid}" ); 	

#start CAMERA   to record audio & video
echo -e "\e[91m..Launch FFMpeg recorder (AUDIO_VIDEO)\e[0m";

ffmpeg -y                                                            \
                                -hide_banner -loglevel info                                     \
    -f v4l2 -framerate 30 -pix_fmt mjpeg                              \
                                -hwaccel auto                  -i /dev/video0                      \
                                -hwaccel auto         -f pulse -i "${SINKB}"                \
        -ss $(( 1 + "$(time_diff_seconds "${epoch_ffplay}" "$(date +'%s')")" )) -i "${PLAYBACK_BETA}" \
                                                                                                       \
                                        -map "0:v:0" -vcodec h264 -t "${PLAYBACK_LENGTH}" "${OUTFILE}" \
                                        -map "1:a:0" -ar 48k "${OUT_DIR}"/"${karaoke_name}"_out.flac   &
                                        
 
# Initialize karaoke_duration variable
export cronos_play=3;
export LC_ALL=C;
rm -rf "${OUT_DIR}/${karaoke_name}_dur.txt";
while [ "$(printf "%.0f" "${cronos_play}")" -le "$(printf "%.0f" "${PLAYBACK_LENGTH}")" ]; do

    wmctrl -R "BETAKe Recording" -b add,above;

    sleep 1.1
    cronos_play="$(echo "scale=4;  ${cronos_play} + 1.1"| bc)";
    percent_play="$(echo "scale=4; ${cronos_play} * 100 / ${PLAYBACK_LENGTH} "  | bc)";
    echo "${cronos_play}" > "${OUT_DIR}/${karaoke_name}_dur.txt";
    echo "${percent_play}";
done | zenity --progress --text="Press OK to STOP recording " \
                    --title="BETAKe Recording" --width=300 --height=200 --percentage=0


# Check if the progress dialog was canceled/completed
if [ $? = 1 ]; then
    echo "Recording canceled.";
else
    echo "Progress completed.";
fi

# Output the final value of karaoke_duration
cronos_play=$( cat "${OUT_DIR}/${karaoke_name}_dur.txt" );
echo "elapsed Karaoke duration: $cronos_play";
echo "Real complete duration: ${PLAYBACK_LENGTH}";

## when prompt window close, stop all recordings 
    # give time to buffers
    sleep 3;
    echo -e "\e[93mRecording finished\e[0m";
            killall -SIGINT ffmpeg;
            killall -HUP v4l2-ctl;
            killall -SIGINT sox;
            killall -9 ffplay;
            
   
# clean up
pactl unload-module module-loopback;

total_ff=$(( 60 * "$(printf "%.0f" "${PLAYBACK_LENGTH}")" ));

##POSTprod
echo "POST_PROCESSING____________________________________"
echo -e "\e[90mrendering final video\e[0m"


# Get total frames using ffprobe
total_final_frames=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_frames -of default=nokey=1:noprint_wrappers=1 "${PLAYBACK_BETA}")

# Start ffmpeg in the background and capture its PID
ffmpeg -y -hide_banner -loglevel info   \
        -ss $(( 1 + "$(time_diff_seconds "${epoch_ffplay}" "$(date +'%s')")" ))  -i "${OUTFILE}" \
                                                                                  -i "${PLAYBACK_BETA}" \
                                                                                  -i "${OUT_DIR}"/"${karaoke_name}"_out.flac \
        -filter_complex "
    [1:a]loudnorm=I=-16:LRA=11:TP=-1.5,   
    aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[playback];
    [2:a]adeclip,anlmdn=s=55,alimiter,speechnorm,
    pan=stereo|c0=c0|c1=c0,acompressor,afftdn,
    ladspa=tap_autotalent:plugin=autotalent:c=480 0 0.0000 0 0 0 0 0 0 0 0 0 0 0 0 1.00 1.00 0 0 0 0 1.000 1.000 0 0 000.0 0.05,
    stereowiden,adynamicequalizer,aexciter,aecho=0.8:0.9:99:0.3,treble=g=5,
    loudnorm=I=-16:LRA=11:TP=-1.5,   
    aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[vocals];

    [playback][vocals]amix=inputs=2:weights=0.5|0.6[betamix];

        [1:v]format=rgba,colorchannelmixer=aa=0.55,scale=s=848x480[v1];
        life=s=848x480,format=rgba[spats];
         gradients=n=7:type=spiral,format=rgb0,scale=s=848x480[vscope];
          [0:v]colorchannelmixer=aa=0.34[v0]; 
          [vscope][v1]hstack=inputs=2,scale=s=848x480[video_merge];
          [spats][video_merge]vstack=inputs=2,format=rgba,colorchannelmixer=aa=0.74,scale=s=848x480[badcoffee];
          [v0][badcoffee]overlay=10:3,format=rgba,scale=s=1270x768[BETAKE];" \
                    -map "[betamix]"  -map "[BETAKE]" \
                                           -t "${PLAYBACK_LENGTH}"   "${OUT_DIR}"/"${karaoke_name}"_beta.avi 2>&1 &
        ffmpeg_pid=$!

# Start zenity progress dialog
(
    while true; do
        # Get current frame number using ffmpeg
        current_frame=$(ffmpeg -i "${OUT_DIR}/${karaoke_name}_beta.avi"  -f null - 2>&1 | tail -n 1 | grep -o "frame= *[0-9]*" | grep -o "[0-9]*" )
        if [ -z "$current_frame" ]; then
            current_frame=0
        fi
        # Calculate progress percentage
        progress=$(echo "scale=0; ${current_frame} * 100 / ${total_final_frames}" | bc)

        # Update zenity progress dialog
        echo "$progress"
        sleep 3; wmctrl -R "avi RENDER in Progress ... please wait" -b add,above;
    done
) | zenity --progress --title="avi RENDER in Progress ... please wait" --text="Encoding video..." --auto-close --auto-kill

# Check if the progress dialog was canceled/completed
if [ $? = 1 ]; then
    echo "Render canceled."
    # Kill ffmpeg process
    killall -9 ffmpeg
    killall -9 ffmpeg
    killall -9 ffmpeg
    killall -9 ffmpeg
else
    # Show the result using ffplay
    ffplay -af "volume=0.45" -window_title "Result" -loglevel quiet \
                    -hide_banner "${OUT_DIR}/${karaoke_name}_beta.avi";
fi


reboot_pulse 'the_end';