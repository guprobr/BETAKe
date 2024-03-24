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
    colorecho "Unload existing modules and restart PulseAudio";
    pactl unload-module module-ladspa-sink;
    pactl unload-module module-loopback;
    pactl unload-module module-echo-cancel;
    colorecho "ERRORS reported above HERE ARE NORMAL. It means already unloaded"; 
    colorecho "\e93m[[[[RESTARTING]]]]  audio server now:";
    killall -HUP pipewire-pulse
    sleep 1; 
}

colorecho() {
    color=$1;
    message=$2;
    # echo with colored escape codes
    case $color in
        "black") coding="\e[30m" ;;
        "red") coding="\e[31m" ;;
        "green") coding="\e[32m" ;;
        "yellow") coding="\e[33m" ;;
        "blue") coding="\e[34m" ;;
        "magenta") coding="\e[35m" ;;
        "cyan") coding="\e[36m" ;;
        "white") coding="\e[37m" ;;
        *) coding="\e[32m" ;;
    esac
    echo -e "${coding}${message}";
}

reboot_pulse 'done';
# Function to kill the parent process and all its children
    kill_parent_and_children() {
        local parent_pid=$1
        local child_pids=$(pgrep -P $parent_pid)

        # Kill the parent process and all its children
        echo "Killing parent process $parent_pid and its children: $child_pids"
        kill $parent_pid $child_pids

        # Optionally, wait for the processes to terminate
        sleep 1

        # Check if the processes are still running
        for pid in $parent_pid $child_pids; do
            if ps -p $pid > /dev/null; then
                echo "Process $pid is still running"
            else
                echo "Process $pid has been terminated"
            fi
        done
    }

# Function to display progress using estimated file size
    render_display_progress() {
        local video_bitrate=512  # Example video bitrate in kbps
        local audio_bitrate=128   # Example audio bitrate in kbps
        local duration_seconds="${PLAYBACK_LEN}"  # Example duration in seconds
        local pid_ffmpeg="$1"     # PID of the ffmpeg process

        # Convert bitrates to bits per second
        local video_bitrate_bps=$((video_bitrate * 1000))
        local audio_bitrate_bps=$((audio_bitrate * 1000))

        # Estimate video size in bits
        local video_size=$((video_bitrate_bps * duration_seconds))

        # Estimate audio size in bits
        local audio_size=$((audio_bitrate_bps * duration_seconds))

        # Calculate total size in bytes
        local total_size_bytes=$(( (video_size + audio_size) / 8 ))

        # Convert bytes to megabytes
        local total_size_mb=$(echo "scale=1; $total_size_bytes / (1024 * 1024)" | bc)

        # Create a dialog box with a progress bar
        (
        while true; do
            # Check if the ffmpeg process is still running
            if ! ps -p "$ff_pid" >/dev/null 2>&1; then
                break
            fi
            wmctrl -r "Rendering" -b add,above
            #wlrctl -R "Rendering"
            #wlrctl -r "Rendering" -b add,above
            # Calculate the percentage of completion based on the file size
            local current_file_size=$(stat -c%s "${1}" )
            local progress=$(echo "scale=1; ($current_file_size * 100) / $total_size_bytes" | bc)

            # Update the progress bar in the dialog
            # this is a foo bar okeyyy
            if [ "$(echo "scale=0; "progress/1 | bc)" -ge 70 ]; then
                progress=65;
            fi
            echo "$progress"

            sleep 0.5
        done
        ) | zenity --progress --title="Rendering" --text="Rendering in progress...please wait" 
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
    local start_epoch_seconds;
    start_epoch_seconds=$(ps -o lstart= -D "%s" -p "$pid")
    echo "$start_epoch_seconds"
}

# Function to get the modification time of a file and convert it to Unix epoch seconds
get_file_modification_time() {
    local file;
    file="$1"
    # Get the modification time of the file
    local mod_time;
    mod_time=$(stat -c %Y "$file")
    echo "$mod_time"
}

# Function to calculate time difference in seconds
time_diff_seconds() {
    local start_secs;
    start_secs="$1"
    local end_secs;
    end_secs="$2"
    colorecho "$(( (end_seconds - start_seconds) ))"
}

# Define log file path
#LOG_FILE="$betake_path/script.log"


# Load configuration variables
SINK="$( pactl get-default-sink )"
SRC_mic="$( pactl get-default-source )"

colorecho "aAjustar vol ${SRC_mic} em 55%";
 pactl set-source-volume "${SRC_mic}" 55%;
colorecho "aAjustar vol default sink 69% USE HEADPHONES";
 pactl set-source-volume "${SINK}"  69%;

pactl load-module module-loopback source="${SRC_mic}" sink="${SINK}";

##DOWNLOAD DO PLAYBACK
#### yt-dlp time!
##
##
## iniciar preparo de adquirir playback e construir pipeline do gravador
PLAYBACK_BETA="${REC_DIR}/${karaoke_name}_playback.mp4";
#remover playbacks antigos para nao dar problema em baixar novos
rm -rf "${REC_DIR}"/"${karaoke_name}"_playback.*;
# Load the video title
PLAYBACK_TITLE="$(yt-dlp --get-title "${video_url}")"
# Download the video
yt-dlp "${video_url}" -o "${REC_DIR}/${karaoke_name}_playback.%(ext)s" --format 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --console-title --embed-subs --progress --no-continue --force-overwrites --default-search "ytsearch: karaoke Lyrics --match-filter duration < 300"; 


# to start converting
export LC_ALL=C;
# Find the first file with either .mp4 or .webm extension
filename=$(find "$REC_DIR" \( -name "${karaoke_name}_playback.mkv" -o -name "${karaoke_name}_playback.mp4" -o -name "${karaoke_name}_playback.webm" \) -print -quit)
# Check if a file was found
if [ -n "$filename" ]; then
    echo "Using file: $filename"

# Get total duration of the video
PLAYBACK_LEN=$( echo "scale=0; $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${filename}")/1" | bc ); 
echo "${PLAYBACK_LEN}";

   #convertemos para avi, pois precisamos usar AVI por enquanto, outros codecs dão bug
   ffmpeg -y -hide_banner -loglevel info -i "${filename}" "${PLAYBACK_BETA}" &
  ff_pid=$!;

render_display_progress "${PLAYBACK_BETA}";

# Check if rendering process was terminated
if [ $? -eq 0 ]; then
    echo "Video rendering completed successfully."
else
    colorecho "red" "Video rendering was cancelled."
    reboot_pulse "true"
    # Get the PID of the parent process
    parent_pid=$$
    # Call the function to kill the parent process and all its children
    kill_parent_and_children $parent_pid
    exit;
fi
      
   colorecho "Playback convertido para AVI";
else
    colorecho "red" "No suitable playback file found."
        reboot_pulse true;
        wmctrl -R "gammaQ CMD prompt";
        wmctrl -c "gammaQ CMD prompt";
        #wlrctl -R "gammaQ CMD prompt";
        #wlrctl -c "gammaQ CMD prompt";
        # Get the PID of the parent process
        parent_pid=$$
        # Call the function to kill the parent process and all its children
        kill_parent_and_children $parent_pid
    exit;
    
fi

if [ ! -n "${PLAYBACK_BETA}" ]; then  
     colorecho "red" "No suitable playback file converted to AVI.";
         reboot_pulse true;
          wmctrl -R "gammaQ CMD prompt";
          wmctrl -c "gammaQ CMD prompt";
          #wlrctl -R "gammaQ CMD prompt";
          #wlrctl -c "gammaQ CMD prompt";
         # Get the PID of the parent process
        parent_pid=$$
        # Call the function to kill the parent process and all its children
        kill_parent_and_children $parent_pid
    exit;
     
fi

colorecho "yellow" "All setup to sing!";
aplay research.wav;
# Display message to start recording
export LC_ALL=C;
zenity --question --text="\"${PLAYBACK_TITLE}\" - duration: ${PLAYBACK_LEN}, let's sing? " --title="Ready to S I N G?" --default-cancel --width=640 --height=100
if [ $? == 1 ]; then
    colorecho "red" "Recording canceled.";
        reboot_pulse true;
    wmctrl -R "gammaQ CMD prompt";
    wmctrl -c "gammaQ CMD prompt";
    #wlrctl -R "gammaQ CMD prompt";
    #wlrctl -c "gammaQ CMD prompt";
    # Get the PID of the parent process
    parent_pid=$$
    # Call the function to kill the parent process and all its children
    kill_parent_and_children $parent_pid
    exit;
fi

rm -rf "${OUT_DIR}"/"${karaoke_name}"_*.*;
# Recording then Post-production
OUT_VIDEO="${OUT_DIR}"/"${karaoke_name}"_out.mp4;
OUT_VOCAL="${OUT_DIR}"/"${karaoke_name}"_out.wav;
	
colorecho "SING!--------------------------";
		colorecho "yellow" "Launch lyrics video";

	            ffplay \
			        -window_title "SING" -loglevel info -hide_banner -af "volume=0.35" "${PLAYBACK_BETA}" &
                ffplay_pid=$!;
                     epoch_ffplay=$( get_process_start_time "${ffplay_pid}" ); 	


#start CAMERA   to record audio & video
colorecho "blue" "..Launch FFMpeg recorder (AUDIO_VIDEO)";
 
       ffmpeg -y \
  -hide_banner -loglevel info \
        -f v4l2 -i /dev/video0 \
        -f pulse -i "${SRC_mic}".monitor \
  -t "${PLAYBACK_LEN}" -map "0:v:0" "${OUT_VIDEO}" \
  -map "1:a:0" -ar 48k "${OUT_VOCAL}" &
ff_pid=$!;
  
    epoch_ff=$( get_process_start_time "${ff_pid}" ); 
    diff_ss="$(( 1 + "$(time_diff_seconds "${epoch_ffplay}" "${epoch_ff}")"))"



# Initialize variables
cronos_play=1
# Main loop
while [ "$(printf "%.0f" "${cronos_play}")" -le "$(printf "%.0f" "${PLAYBACK_LEN}")" ]; do
    wmctrl -r "Recording" -b add,above
    #wlrctl -R "Recording"
    #wlrctl -r "Recording" -b add,above
    sleep 1.1
    cronos_play=$(echo "scale=6; ${cronos_play} + 1.1" | bc)
    percent_play=$(echo "scale=6; ${cronos_play} * 100 / ${PLAYBACK_LEN}" | bc)
    echo "${cronos_play}" > "${OUT_DIR}/${karaoke_name}_dur.txt"
    echo "$(printf "%.0f" "${percent_play}")"
done | zenity --progress --text="Press OK to STOP recording" \
              --title="Recording" --width=300 --height=200 --percentage=0



# Check if the progress dialog was canceled/completed
if [ $? = 1 ]; then
    colorecho "red" "Recording canceled.";
    
else
    colorecho "cyan" "Progress completed.";
fi
pactl unload-module module-loopback;
# Output the final value of karaoke_duration
cronos_play=$( cat "${OUT_DIR}/${karaoke_name}_dur.txt" );
echo "elapsed Karaoke duration: $cronos_play";
echo "Total playback duration: ${PLAYBACK_LEN}";

## when prompt window close, stop all recordings 
    # give some time to ffmpeg graceful finish
    
    colorecho "Recording finished";
            killall -SIGINT ffmpeg;
            killall -HUP v4l2-ctl;
            killall -SIGINT sox;
            killall -9 ffplay;
    sleep 5;        
   

##POSTprod
echo "POST_PROCESSING____________________________________"
colorecho "blue" "rendering final video"

export LC_ALL=C;  OUT_FILE="${OUT_DIR}"/"${karaoke_name}"_beta.mp4;
# Start ffmpeg in the background and capture its PID
ffmpeg -y -hide_banner -loglevel info   \
                                                                                -i "${OUT_VIDEO}" \
    -ss "$( echo "scale=4; ${diff_ss} + 0.9695" | bc | sed 's/-\./-0\./g')"0    -i "${PLAYBACK_BETA}" \
                                                                                -i "${OUT_VOCAL}" \
        -filter_complex "
    [2:a]
    adeclip,alimiter,speechnorm,
    pan=stereo|c0=c0|c1=c0,acompressor,rubberband=pitch=1.0296:tempo=1,
    ladspa=tap_autotalent:plugin=autotalent:c=441 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.84 0.98 0 0 0 0 1.000 1.000 0 0 000.0 1.00,
   stereowiden,adynamicequalizer,aexciter,aecho=0.6:0.7:56:0.36,treble=g=3,
    loudnorm=I=-16:LRA=11:TP=-1.5,   
    aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[vocals];

    [1:a]dynaudnorm,aecho=0.8:0.6:128:0.25,   
    aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[playback];

    [playback][vocals]amix=inputs=2:weights=0.6|0.4[gammaQ];

        [1:v]format=rgba,colorchannelmixer=aa=0.84,scale=s=424x240[v1];
        life=s=424x240:mold=5:r=10:ratio=0.1:death_color=blue:life_color=#00ff00,boxblur=2:2,format=rgba[spats];
         gradients=n=3:type=spiral,format=rgb0,scale=s=424x240[vscope];
          [0:v]scale=s=848x408[v0]; 
          [vscope][v1]hstack=inputs=2,scale=s=424x240[video_merge];
          [video_merge][spats]vstack=inputs=2,format=rgba,colorchannelmixer=aa=0.66,scale=s=848x408[badcoffee];
          [v0][badcoffee]overlay=10:10,format=rgba,scale=s=848x408[BETAKE];" \
                    -map "[gammaQ]"  -map "[BETAKE]" \
                    -ar 48k -t "${PLAYBACK_LEN}"   "${OUT_FILE}"  &
                ff_pid=$!;

render_display_progress "${OUT_FILE}";
generate_mp3 "${OUT_FILE}" "${OUT_FILE%.*}".mp3;
    
ffplay -window_title "Obrigado pela participação!" "${OUT_FILE}";
wmctrl -R "gammaQ CMD prompt";
wmctrl -c "gammaQ CMD prompt";
#wlrctl -R "gammaQ CMD prompt";
#wlrctl -c "gammaQ CMD prompt";
reboot_pulse 'the_end';
exit;
