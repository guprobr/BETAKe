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
LOG_FILE="$betake_path/script.log"


echo -e "\e[93mUnload existing modules and restart PulseAudio\e[0m"
pactl unload-module module-ladspa-sink
pactl unload-module module-loopback
pactl unload-module module-echo-cancel
echo -e "\e[91mERRORS reported above HERE ARE NORMAL. restarting audio server now:\e[0m"
killall -HUP pipewire-pulse
sleep 3;
# Load configuration variables

SINKA="beta_loopy"
SINKB="beta_kombo"
echo -e "\e[93m*HOUSEKEEPING SOUND SERVERS*\e[0m";
echo -e "\e[91mINIT MIC\"SINK A\"\e[0m";
echo -e "\e[93mLoading module-remap-source for microphone sink\e[0m";
pactl load-module module-remap-source source_name=${SINKA} master="$(pactl list short sources | grep alsa_input | head -n1 | \awk '{ print $2 }')";

#"Load the echo cancellation module to cancel echo";

echo -e "\e[96mLoad module-echo-cancel\e[0m";
pactl load-module module-echo-cancel sink_name="echocan" master="${SINKA}" \
    aec_method=webrtc aec_args="analog_gain_control=1 digital_gain_control=1";

#Load Ladspa effects
#
#LADSPA_rnnoise
echo -e "\e[95mLoad module-ladspa-sink for RNNOISE\e[0m"
pactl load-module module-ladspa-sink sink_name=LADSPA_rnnoise plugin="librnnoise_ladspa" label=noise_suppressor_stereo \
                                control="80,80,85,95,85,100,200" master="echocan";
#LADSPA_declip
echo -e "\e[94mLoad module-ladspa-sink for declipper\e[0m"
pactl load-module module-ladspa-sink sink_name="LADSPA_declip" plugin="declip_1195" label=declip \
                                control="0.05,0.05" master=LADSPA_rnnoise;
#LADSPA_pitch
echo -e "\e[92mLoad module-ladspa-sink for pitch\e[0m"
pactl load-module module-ladspa-sink sink_name=LADSPA_pitch plugin="tap_pitch" label=tap_pitch \
                                control="5,12,1,1,1" master=LADSPA_declip;
#LADSPA_autotalent
echo -e "\e[91mLoad module-ladspa-sink for AutoTalenttch\e[0m"
pactl load-module module-ladspa-sink sink_name="${SINKB}" plugin="tap_autotalent" label=autotalent control="" \
                control="480,0,0.0000,0,0,0,0,0,0,0,0,0,0,0,0,1.00,1.00,0,0,0,0,1.000,1.000,0,0,000.0,0.5" \
                                                master=LADSPA_pitch;


PLAYBACK_BETA="${REC_DIR}/${karaoke_name}_playback.mp4";
echo -e "\e[93maAjustar vol do microfone\e[0m";
pactl set-source-volume "${SINKA}" 55%
echo -e "\e[92maAtivando monitor do microfone\e[0m";
pactl load-module module-loopback source=${SINKB} sink="$( pactl list sinks short | grep output | head -n1 | awk '{ print $2 }' )"
pavumeter &

#remover playbacks antigos para nao dar problema em baixar novos
rm -rf "${REC_DIR:?}"/"${karaoke_name:?}"_playback.*;
echo -e "\e[95mDOWNLOAD video with [yt-dl]";
# Load the video title
PLAYBACK_TITLE="$(yt-dlp --get-title "${video_url}")"
# Download the video
yt-dlp "${video_url}" -o "${REC_DIR}/${karaoke_name}_playback.%(ext)s" --format 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --console-title --embed-subs --progress --no-continue --force-overwrites --default-search "ytsearch: karaoke Lyrics --match-filter duration < 300"; 


# Display message to start converting
export LC_ALL=C;
zenity --question --text="Going to convert: \"${PLAYBACK_TITLE}\" - duration: \"$(printf "%.0f" "${PLAYBACK_LENGTH}")\", do you want this playback? " --title="BETAKe Recording Prompt" --default-cancel --width=200 --height=100
if [ $? == 1 ]; then
    echo "Recording canceled.";
    wmctrl -c 'BETAKê CMD prompt';
    exit;
fi

# Find the first file with either .mp4 or .webm extension
filename=$(find "$REC_DIR" \( -name "${karaoke_name}_playback.mkv" -o -name "${karaoke_name}_playback.mp4" -o -name "${karaoke_name}_playback.webm" \) -print -quit)
# Check if a file was found
if [ -n "$filename" ]; then
    echo "Using file: $filename"
    # Call ffmpeg with the found filename
    echo -e "\e[93mCONVERTING playback to [avi]";
    ffmpeg -hide_banner -loglevel info -y \
                -i "${filename}" \
                  -ar 48k  "${PLAYBACK_BETA}";
else
    echo "No suitable playback file found."
    exit
fi

if [ ! -n "${PLAYBACK_BETA}" ]; then  
     echo "No suitable playback file converted to AVI.";
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
    wmctrl -c 'BETAKê CMD prompt';
    exit;
fi

# Recording and Post-production
OUTFILE="${OUT_DIR}/${karaoke_name}_out.avi";
	
echo -e "\e[93mSING!--------------------------\e[0m";
echo -e "\e[91m..Launch FFMpeg integrated recorder (AUDIO_VIDEO)\e[0m";
		echo -e "\e[99mLaunch lyrics video\e[0m";

	            ffplay \
			        -window_title "SING" -loglevel info -hide_banner -af "volume=0.35" "${PLAYBACK_BETA}" &
                ffplay_pid=$!;

                     epoch_ffplay=$( get_process_start_time "${ffplay_pid}" ); 	

#start CAMERA   
  ffmpeg -y                                                          \
    -hide_banner -loglevel info  -hwaccel auto                         \
            -f v4l2 -framerate 90 -video_size 1280x720                 \
                                    -i /dev/video0                      \
                        -f pulse    -i "${SINKB}"                        \
     -ss $(( 1 + "$(time_diff_seconds "${epoch_ffplay}" "$(date +'%s')")" )) -i "${PLAYBACK_BETA}"  \
                                                                           \
    -filter_complex "[1:a][2:a]amix=inputs=2:weights=0.5|0.6[betamix];"     \
        -map "[betamix]" -map "0:v:0" -ar 48k                                      \
                       -t "${PLAYBACK_LENGTH}" "${OUTFILE}" &

 
    


    echo -e "\e[95m..Acquired PLAYBACK process PID ${ffplay_pid} _ (sync mechanism)\e[0m"

    # try to fix echo cancel bug
    ffplay -af "volume=3.5" -hide_banner -loglevel quiet -f pulse -i ${SINKB} research.wav &

# new integrated recorder all-in-one FFMpeg
# Initialize karaoke_duration variable
export cronos_play=1;
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
total_final_frames=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_frames -of default=nokey=1:noprint_wrappers=1 "${OUTFILE}")

# Start ffmpeg in the background and capture its PID
ffmpeg -y -hide_banner -loglevel info   \
        -ss $(( 1 + "$(time_diff_seconds "${epoch_ffplay}" "$(date +'%s')")" )) -i "${PLAYBACK_BETA}" \
                                                                                -i "${OUTFILE}" \
        -filter_complex "
    [1:a]adeclip,alimiter,speechnorm,
    pan=stereo|c0=c0|c1=c0,acompressor,
    ladspa=tap_autotalent:plugin=autotalent:c=440 0 0.0000 0 0 0 0 0 0 0 0 0 0 0 0 1.00 1.00 0 0 0 0 1.000 1.000 0 0 000.0 0.045,
    stereowiden,adynamicequalizer,aexciter,treble=g=2,loudnorm=I=-16:LRA=11:TP=-1.5,
    aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[master];
        [1:v]scale=s=1920x1080[v1];
        life=s=1920x1080[spats];
         [0:a]avectorscope=m=polar:s=1920x1080[vscope];
          [0:v]scale=s=1920x1080[v0]; 
          [vscope][v1]hstack=inputs=2,scale=s=1920x1080[video_merge];
          [spats][video_merge]vstack=inputs=2,format=rgba,colorchannelmixer=aa=0.34,scale=s=1920x1080[badcoffee];
          [v0][badcoffee]overlay=10:8,format=rgba,scale=s=1920x1080[BETAKE];" \
                    -map "[master]"  -map "[BETAKE]" \
                                           -t "${PLAYBACK_LENGTH}"   "${OUT_DIR}"/"${karaoke_name}"_beta.mp4 &
        ffmpeg_pid=$!

# Start zenity progress dialog
(
    while true; do
        # Get current frame number using ffmpeg
        current_frame=$(ffmpeg -i "${OUT_DIR}"/"${karaoke_name}"_beta.mp4 -vf "select='eq(n\,0)'" -vsync vfr -vframes 1 -f null - 2>&1 | grep -o "frame= *[0-9]*" | grep -o "[0-9]*" || true)
        if [ -z "$current_frame" ]; then
            current_frame=0
        fi
        # Calculate progress percentage
        progress=$((current_frame * 100 / total_final_frames))

        # Update zenity progress dialog
        echo "$progress"
        sleep 0.5
    done
) | zenity --progress --title="FFmpeg FINAL RENDER Progress" --text="Encoding video..." --auto-close --auto-kill
# Check if the progress dialog was canceled/completed
if [ $? = 1 ]; then
    echo "render canceled.";
else
    echo "Progress completed.";
    # Show the result using ffplay
    ffplay -af "volume=0.45" -window_title  "Results" -loglevel quiet \
                    -hide_banner "${OUT_DIR}"/"${karaoke_name}"_beta.mp4 &
fi
# Kill ffmpeg process
pkill -9 ffmpeg



