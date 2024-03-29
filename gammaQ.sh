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
    echo -e "${coding}${message}\e[0m";
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

            # Calculate the percentage of completion based on the file size
            local current_file_size;
            current_file_size=$(stat -c%s "${1}" )
            local progress;
            progress=$(echo "scale=0; ($current_file_size * 45) / $total_size_bytes " | bc)

            
            echo "$progress"

            sleep 1;
        done
        ) | zenity --progress --title="Rendering" --text="Rendering in progress...please wait" --auto-close --auto-kill
    }

# Function to generate MP3 from MP4
generate_mp3() {
    local mp4_file="$1"
    local mp3_file="$2"
    ffmpeg -y -hide_banner -loglevel error -i "$mp4_file" -vn -acodec libmp3lame "$mp3_file"
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
    echo "$(echo "scale=6; (${end_secs} - ${start_secs}) " | bc)"
}


# Define log file path
#LOG_FILE="$betake_path/script.log"
# Load configuration variables

SINK="$( pactl get-default-sink )"
colorecho "yellow" " got sink: $SINK";
SRC_mic="$( pactl get-default-source )"
colorecho "green" " got mic src: $SRC_mic";

colorecho "aAjustar vol ${SRC_mic} em 45%";
 pactl set-source-volume "${SRC_mic}" 45%;
colorecho "aAjustar vol default sink 69% USE HEADPHONES";
 pactl set-source-volume "${SINK}"  69%;

pactl load-module module-loopback & 


##DOWNLOAD DO PLAYBACK
#### yt-dlp time!
colorecho "yellow" "Try upd yt-dlp";
yt-dlp -U;
PLAYBACK_BETA="${REC_DIR}/${karaoke_name}_playback.mp4";
#remove old playbacks
rm -rf "${REC_DIR}"/"${karaoke_name}"_playback.*;
# fetch the video title
PLAYBACK_TITLE="$(yt-dlp --get-title "${video_url}")"
colorecho "magenta" "Found video: ${PLAYBACK_TITLE}";
# Download the video, it will cache the original and copy the playback
filename=$(yt-dlp "${video_url}" --get-filename --format 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --default-search "ytsearch: karaoke Lyrics --match-filter duration < 300")
yt-dlp "${video_url}" -o "${REC_DIR}/$filename" --format 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --console-title --quiet --embed-subs --no-continue --default-search "ytsearch: karaoke Lyrics --match-filter duration < 300"
cp "${REC_DIR}/$filename" "${PLAYBACK_BETA}";

# perphaps convert
export LC_ALL=C;
# Find the first file with either .mp4 or .webm extension
filename=$(find "$REC_DIR" \( -name "${karaoke_name}_playback.mkv" -o -name "${karaoke_name}_playback.mp4" -o -name "${karaoke_name}_playback.webm" \) -print -quit)
# Check if a file was found
if [ -n "$filename" ]; then
    echo "Using file: $filename"
# Get total duration of the video and cast to integer
PLAYBACK_LEN=$( echo "scale=0; $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${filename}")/1" | bc ); 
colorecho "yello" "Playback length: ${PLAYBACK_LEN}";
ffmpeg -y -hide_banner -loglevel error "$filename" "$PLAYBACK_BETA";

else
    colorecho "red" "No suitable playback file found."
        # Get the PID of the parent process
        parent_pid=$$
        # Call the function to kill the parent process and all its children
        kill_parent_and_children $parent_pid
        killall -9 gst-launch-1.0;
    exit;
    
fi

colorecho "cyan" "All setup to sing!";
# Display message to start recording
export LC_ALL=C;
zenity --question --text="\"${PLAYBACK_TITLE}\", let's sing? " --title="Ready to S I N G?" --default-cancel --width=640 --height=100
if [ $? == 1 ]; then
    colorecho "red" "Recording aborted.";
    # Get the PID of the parent process
    parent_pid=$$
    # Call the function to kill the parent process and all its children
    kill_parent_and_children $parent_pid
            killall -9 gst-launch-1.0;
    exit;
fi

rm -rf "${OUT_DIR}"/"${karaoke_name}"_*.*;
# Recording then Post-production
OUT_VIDEO="${OUT_DIR}"/"${karaoke_name}"_out.mp4;
OUT_VOCAL="${OUT_DIR}"/"${karaoke_name}"_out.wav;
	
colorecho "SING!--------------------------";
		colorecho "yellow" "Launch lyrics video";

	            ffplay -left +0 \
                        -top -0 \
			        -window_title "SING" -loglevel quiet -hide_banner \
                    -af "volume=0.15" \
                    -noborder -exitonkeydown  \
                    -vf "scale=1280:720" "${PLAYBACK_BETA}" &
                ffplay_pid=$!;
            
            epoch_ffplay=$( get_process_start_time  ); 	
                colorecho "red" "ffplay start: $epoch_ffplay";

vidformat=$(v4l2-ctl --list-formats-ext | grep -e '\[[0-9]\]' | head -n1 | awk '{ print $2 }');
vidresolut=$(v4l2-ctl --list-formats-ext | grep -A2 -e '\[[0-9]\]' | grep Size | head -n1 | awk '{ print $3 }');


guvcview --video="${OUT_VIDEO}" -e --gui=none --render=sdl --video_timer="${PLAYBACK_LEN}" --video_codec=h264 \
    --audio="pulse" --audio_device="${SRC_mic}" --audio_codec=aac \
        -x "${vidresolut}" -F60 -m 1280x720 \
            --format="${vidformat}" &
        gvc_pid=$!;

 epoch_gvc=$( get_process_start_time )
    colorecho "green" "guvcview start: $epoch_gvc";
    diff_ss="$(time_diff_seconds "${epoch_ffplay}" "${epoch_gvc}")"
        colorecho "magenta" "diff_ss: $diff_ss";
   

cronos_play=1
while [ "$(printf "%.0f" "${cronos_play}")" -le "$(printf "%.0f" "${PLAYBACK_LEN}")" ]; do
    xdotool search --name "Recording" windowactivate
    xdotool search --name  "Guvcview*" windowactivate
    sleep 1
    cronos_play=$(( "$cronos_play" + 1 ));
    # shellcheck disable=SC2005
    echo $(( ("$cronos_play"*100) / "$PLAYBACK_LEN" ))
            # Check if the webcam process is still running
            if ! ps -p "$gvc_pid" >/dev/null 2>&1; then
                break
            fi
            # Check if the player process is still running
            if ! ps -p "$ffplay_pid" >/dev/null 2>&1; then
                break
            fi
done | zenity --progress --text="Pressing will STOP recorder and start render post-production MP4" \
              --title="Recording" --width=300 --height=200 --percentage=0

# Check if the progress dialog was canceled OR completed
if [ $? = 1 ]; then
    colorecho "red" "Recording skipped.";
else
    colorecho "cyan" "Progress completed.";
fi

colorecho "blue" "Actual playback duration: ${PLAYBACK_LEN}";
colorecho "red" "Calculated diff sync: $diff_ss";

# give 5sec for recorder graceful finish
    
    colorecho "Recording finished";
            killall -SIGINT guvcview;
            killall -9 ffplay;
    
    sleep 5;        
   

##POSTprod
VOCAL_FILE="${OUT_DIR}"/"${karaoke_name}"_sox.wav;

colorecho "yellow" "[AuDIO] Apply shibata dithering with SoX, also noise reduction...";
mv -v "${OUT_DIR}"/"${karaoke_name}"_out-1.mp4 "${OUT_VIDEO}"; 

ffmpeg -hide_banner -loglevel error -i "${OUT_VIDEO}" "${VOCAL_FILE}";
sox "${VOCAL_FILE}" -n trim 0 5 noiseprof "$OUT_DIR"/"$karaoke_name".prof;
sox "${VOCAL_FILE}" "${OUT_VOCAL}" \
    noisered "$OUT_DIR"/"$karaoke_name".prof 0.3 \
                            dither -s -f shibata;
colorecho "yellow" "[AuDIO] Apply vocal tuning algorithm...";
lv2file -i "${OUT_VOCAL}" -o "${VOCAL_FILE}" \
 -p pitch_factor:4.0 \
 -p effect:0 -p fc_voc_switch:0 -p fc_voc:1 \
 -p pitch_correction:1 -p threshold:2.9 -p attack:0.1 \
 -p transpose:0 -p c:0 -p cc:0 -p d:0 -p dd:0 -p e:0 -p f:0 -p ff:0 -p g:0 -p gg:0 -p a:0 -p aa:0 -p b:0 \
 -m -c 1:voice  http://hyperglitch.com/dev/VocProc;

#trim "${diff_ss}" ladspa=autotalent:plugin=autotalent:c=440 0.00 0.0000 0 0 0 0 0 0 0 0 0 0 0 0 1.00 1.00 0 0 0 0.000 0.000 0.000 0 0 000.0 1.00,
        pactl unload-module module-loopback;

colorecho "red" "rendering final video"

export LC_ALL=C;  
OUT_FILE="${OUT_DIR}"/"${karaoke_name}"_beta.mp4;

ffmpeg -y -hide_banner -loglevel error -stats  \
    -ss "$( printf "%0.8f" "$( echo "scale=8; ${diff_ss} * -1 " | bc )" )"  -i "${OUT_VIDEO}" \
    -ss "$( printf "%0.8f" "$( echo "scale=8; ${diff_ss} * -10 " | bc )" )"  -i "${PLAYBACK_BETA}" \
                                                                       -i "${OUT_VOCAL}" \
    -filter_complex "
    [2:a]
    adeclip,compensationdelay,alimiter,speechnorm,acompressor,
    ladspa=tap_pitch:plugin=tap_pitch:c=0.5 90 -20 16,
    aecho=0.8:0.7:90:0.21,
        aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
        aresample=resampler=soxr:osf=s16:precision=33[vocals];

    [1:a]dynaudnorm,volume=volume=0.45,
    aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[playback];

    [playback][vocals]amix=inputs=2;

      [1:v]scale=s=640x360[v1];
        gradients=n=4:s=640x360,format=rgba[vscope];
        [0:v]tile=layout=2x2,colorize=hue=$((RANDOM%361)):saturation=$(bc <<< "scale=2; $RANDOM/32767"):lightness=$(bc <<< "scale=2; $RANDOM/32767"),
        scale=s=640x360[v0];
        [v1][vscope]xstack,scale=s=640x360[badcoffee];
        [v0][badcoffee]vstack;" \
            -t "${PLAYBACK_LEN}" \
     -c:v libx264 -movflags faststart \
       -c:a aac  -ar 44100  -s "$vidresolut" \
         "${OUT_FILE}"   &
           ff_pid=$!;

FINAL_FILE="${OUT_FILE}";



render_display_progress "${OUT_FILE}" $ff_pid;

    colorecho "green" "Done. Generating MP3 too";

generate_mp3 "${FINAL_FILE}" "${OUT_FILE%.*}".mp3;
    
ffplay -window_title "Obrigado pela participação! sync diff: ${diff_ss}" "${FINAL_FILE}";
exit;
