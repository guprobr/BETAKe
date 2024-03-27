#!/bin/bash

karaoke_name="$1"
video_url="$2"
betake_path="$3"

if [ "${karaoke_name}" == "" ]; then karaoke_name="BETA"; fi
if [ "${video_url}" == "" ]; then video_url=" --simulate "; fi
if [ "${betake_path}" == "" ]; then betake_path="./"; fi

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


# Function to kill the parent process and all its children
    kill_parent_and_children() {
        local parent_pid=$1
        local child_pids;
        child_pids=$(pgrep -P "$parent_pid")

        # Kill the parent process and all its children
        echo "Killing parent process $parent_pid and its children: $child_pids"
        kill "$parent_pid" "$child_pids"

        # Optionally, wait for the processes to terminate
        sleep 1

        # Check if the processes are still running
        for pid in $parent_pid $child_pids; do
            if ps -p "$pid" > /dev/null; then
                echo "Process $pid is still running"
            else
                echo "Process $pid has been terminated"
            fi
        done
    }

# Function to display progress using estimated file size
    render_display_progress() {
        local video_bitrate=5120  # Example video bitrate in kbps
        local audio_bitrate=1280   # Example audio bitrate in kbps
        local duration_seconds="${PLAYBACK_LEN}"  # Example duration in seconds
        local pid_ffmpeg="$2"     # PID of the ffmpeg process

        # Convert bitrates to bits per second
        local video_bitrate_bps=$((video_bitrate * 1000))
        local audio_bitrate_bps=$((audio_bitrate * 1000))

        # Estimate video size in bits
        local video_size=$((video_bitrate_bps * duration_seconds))

        # Estimate audio size in bits
        local audio_size=$((audio_bitrate_bps * duration_seconds))

        # Calculate total size in bytes
        local total_size_bytes=$(( (video_size + audio_size) / 8 ))

        # Create a dialog box with a progress bar
        (
        while true; do
            # Check if the ffmpeg process is still running
            if ! ps -p "$pid_ffmpeg" >/dev/null 2>&1; then
                break
            fi
            wmctrl -r "Rendering" -b add,above
            #wlrctl -R "Rendering"
            #wlrctl -r "Rendering" -b add,above
            # Calculate the percentage of completion based on the file size
            local current_file_size;
            current_file_size=$(stat -c%s "${1}" )
            local progress;
            progress=$(echo "scale=0; ($current_file_size * 25) / $total_size_bytes " | bc)

            
            echo "$progress"

            sleep 1;
        done
        ) | zenity --progress --title="Rendering" --text="Rendering in progress...please wait" --auto-close --auto-kill
    }

# Function to generate MP3 from MP4
generate_mp3() {
    local mp4_file="$1"
    local mp3_file="$2"
    ffmpeg -y -hide_banner -loglevel error -i "$mp4_file" -vn -acodec libmp3lame -q:a 4 "$mp3_file"
}

# Function to get the start time of a process in Unix epoch seconds with %s format
get_process_start_time() {
    # Get the start time of the process in Unix epoch seconds
    local start_epoch_sec_ns;
    start_epoch_sec_ns=$(date +%s.%N)
    echo "$start_epoch_sec_ns"
}


# Function to calculate time difference in seconds
time_diff_seconds() {
    local start_secs;
    start_secs="$1";
    local end_secs;
    end_secs="$2";
    # shellcheck disable=SC2005
    echo "$(echo "scale=6; ${end_secs} - ${start_secs}" | bc)"
}

# Define log file path
#LOG_FILE="$betake_path/script.log"
reboot_pulse 'done';

# Load configuration variables

SINK="$( pactl get-default-sink )"
colorecho "yellow" " got sink: $SINK";
SRC_mic="$( pactl get-default-source )"
colorecho "green" " got mic src: $SRC_mic";

colorecho "aAjustar vol ${SRC_mic} em 45%";
 pactl set-source-volume "${SRC_mic}" 45%;
colorecho "aAjustar vol default sink 69% USE HEADPHONES";
 pactl set-source-volume "${SINK}"  69%;

pactl load-module module-loopback source="${SRC_mic}" sink="${SINK}";

##DOWNLOAD DO PLAYBACK
#### yt-dlp time!
PLAYBACK_BETA="${REC_DIR}/${karaoke_name}_playback.mp4";
#remove old playbacks
rm -rf "${REC_DIR}"/"${karaoke_name}"_playback.*;
# fetch the video title
PLAYBACK_TITLE="$(yt-dlp --get-title "${video_url}")"
colorecho "magenta" "Found video: ${PLAYBACK_TITLE}";
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
colorecho "yello" "Playback length: ${PLAYBACK_LEN}";

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

colorecho "cyan" "All setup to sing!";
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
			        -window_title "SING" -loglevel info -hide_banner -af "volume=0.15" "${PLAYBACK_BETA}" &
                #ffplay_pid=$!;
            epoch_ffplay=$( get_process_start_time  ); 	
                colorecho "red" "ffplay start: $epoch_ffplay";

#start CAMERA   to record audio & video
colorecho "blue" "..Launch FFMpeg recorder (AUDIO_VIDEO)";
 
 ffmpeg -y \
-hide_banner -loglevel info    \
-f v4l2     -i /dev/video0      \
-f pulse    -i "${SRC_mic}".monitor \
-t "${PLAYBACK_LEN}"                \
   -an  -c:v libx264 -preset:v faster -crf:v 23 -g 60 -pix_fmt yuv420p -movflags +faststart         "${OUT_VIDEO}" \
        -c:a pcm_s16le  -ar 44100 "${OUT_VOCAL}" &
    ff_pid=$!;
  
    epoch_ff=$( get_process_start_time )
        colorecho "red" "ffmpeg start: $epoch_ff";

    diff_ss="$(time_diff_seconds "${epoch_ffplay}" "${epoch_ff}")"
        colorecho "yellow" "diff_ss: $diff_ss";


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
    # shellcheck disable=SC2005
    echo "$(printf "%.0f" "${percent_play}")"
done | zenity --progress --text="Press to STOP recording" \
              --title="Recording" --width=300 --height=200 --percentage=0



# Check if the progress dialog was canceled/completed
if [ $? = 1 ]; then
    colorecho "red" "Recording canceled.";
    
else
    colorecho "cyan" "Progress completed.";
fi
pactl unload-module module-loopback;

echo "Total playback duration: ${PLAYBACK_LEN}";
colorecho "red" "diff sync: $diff_ss";

## when prompt window close, stop all recordings 
    # give some time to ffmpeg graceful finish
    
    colorecho "Recording finished";
            killall -SIGINT ffmpeg;
            #killall -HUP v4l2-ctl;
            #killall -SIGINT sox;
            killall -9 ffplay;
    
    sleep 5;        
   

##POSTprod
colorecho "blue" "rendering final video"

export LC_ALL=C;  
OUT_FILE="${OUT_DIR}"/"${karaoke_name}"_beta.mp4;

ffmpeg -y -hide_banner -loglevel info  \
    -ss "$( printf "%0.4f" "$( echo "scale=4; ${diff_ss}  " | bc )" )" -i "${OUT_VIDEO}" \
    -ss "$( printf "%0.4f" "$( echo "scale=4; ${diff_ss}  " | bc )" )" -i "${PLAYBACK_BETA}" \
                                                                       -i "${OUT_VOCAL}" \
                                                                                -filter_complex "
    [2:a]
    afftdn=nr=15,compensationdelay,alimiter,speechnorm,acompressor,
    ladspa=tap_pitch:plugin=tap_pitch:c=0.5 90 -20 20,
    ladspa=tap_autotalent:plugin=autotalent:c=440 1.6726875 0.0000 0 0 0 0 0 0 0 0 0 0 0 0 1.00 1.00 0 0 0 0.33825 0.000 0.000 0 0 000.0 0.33,
    aecho=0.8:0.7:99:0.13,
    aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16
    [vocals];

    [1:a]aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
        aresample=resampler=soxr:osf=s16[playback];

    [playback][vocals]amix=inputs=2:weights=0.25|0.33;

      [1:v]scale=s=640x360[v1];
        gradients=n=7:type=circular:s=640x360,scale=s=640x360[spats];
        gradients=n=6:type=spiral:s=640x360[vscope];
        [spats][vscope]overlay=alpha=0.6[spatscope];
        [1:a]avectorscope=s=640x360[frodo];
        [0:v]colorize=hue=$((RANDOM%361)):saturation=$(bc <<< "scale=2; $RANDOM/32767"):lightness=$(bc <<< "scale=2; $RANDOM/32767"),
        scale=s=640x360[v0]; 
        [spatscope]scale=s=640x360[scopy];
        [v1][frodo]hstack,scale=s=640x360[video_merge];
        [scopy][video_merge]hstack,scale=s=640x360[badcoffee];
          
        [v0][badcoffee]vstack,scale=s=1280x720;" \
             -ar 44100 -t "${PLAYBACK_LEN}" \
     -c:v libx264 -movflags faststart  \
       -c:a aac \
         "${OUT_FILE}"  &
           ff_pid=$!;

FINAL_FILE="${OUT_FILE}";

render_display_progress "${OUT_FILE}" $ff_pid;

    colorecho "green" "Done. Generating MP3 too";

generate_mp3 "${OUT_VOCAL}" "${OUT_FILE%.*}".mp3;
    
ffplay -window_title "Obrigado pela participação! sync diff: ${diff_ss}" "${FINAL_FILE}";
wmctrl -R "gammaQ CMD prompt";
wmctrl -c "gammaQ CMD prompt";
#wlrctl -R "gammaQ CMD prompt";
#wlrctl -c "gammaQ CMD prompt";
reboot_pulse 'the_end';
exit;
