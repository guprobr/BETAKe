#!/bin/bash

karaoke_name="$1";
video_url="$2";
betake_path="$3";
video_dev="$4";

if [ "${karaoke_name}" == "" ]; then karaoke_name="BETA"; fi
if [ "${video_url}" == "" ]; then video_url=" --simulate "; fi
if [ "${betake_path}" == "" ]; then betake_path="${HOME}/gammaQ/"; fi
if [ "${video_dev}" == "" ]; then video_dev="/dev/video0"; fi

# Configuration
REC_DIR="$betake_path/recordings"   # Directory to store recordings
OUT_DIR="$betake_path/outputs"      # Directory to store output files

    cd "${betake_path}" || exit;

    mkdir -p "$REC_DIR" || exit; # It happened once, far far away from these lands,
    mkdir -p "$OUT_DIR" || exit; # a very recent fact indeed, those directories being erased
                                ###### goddam, boss!
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
    echo -e "${coding}${message} 🎵 𝄞\e[0m";
}

translate_vid_format() {
    case "$1" in
        YUYV) echo "yuyv422";;
        UYVY) echo "uyvy422";;
        NV12) echo "nv12";;
        NV21) echo "nv21";;
        YV12) echo "yuv420p";;
        YV16) echo "yuv422p";;
        YV24) echo "yuv444p";;
        RGB3) echo "rgb24";;
        RGB4) echo "bgr24";;
        GREY) echo "gray";;
        *) echo "mjpeg";;
    esac
}


# Function to kill the parent process and all its children
    kill_parent_and_children() {
        local parent_pid=$1
        local child_pids;
        child_pids=$(pgrep -P "$parent_pid")

                    pactl unload-module module-loopback;

        # Kill the parent process and all its children
        echo "Killing parent process $parent_pid and its children: $child_pids"
        kill "$parent_pid" "$child_pids"

        # Optionally, wait for the processes to terminate
        sleep 1

        # Check if the processes are still running
        for pid in $parent_pid $child_pids; do
            if ps -p "$pid" > /dev/null; then
                colorecho "red" "Process $pid is still running"
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
        ) | zenity --progress --title="Rendering" --text="Rendering in progress...please wait" --pulsate --auto-close
    
        # if it was cancelled, kill, else it wont kill anybody thats already dead, boss.
        kill -9 "${pid_ffmpeg}" >/dev/null 2>&1;

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

launch_ffmpeg_webcam() {
		
best_format=$(v4l2-ctl --list-formats-ext -d "${video_dev}" | grep -e '\[[0-9]\]' | awk '{ print $2 " " $3 }' | sort -k2 -n | tail -n1 | awk '{ print $1 }')
video_res=$(v4l2-ctl --list-formats-ext -d "${video_dev}" | \
                           awk -v fmt="${best_format}" '$0 ~ fmt {f=1} f && /Size/ {print $3; f=0}' | \
                           sort -k1 -n | tail -n1 );
video_fmt=$(translate_vid_format "${best_format}")

colorecho "green" "FFmpeg format name: ${video_fmt}";
colorecho "cyan" "Best resolution: ${video_res}";

ffmpeg -loglevel error -hide_banner -stats -stats_period 5s  -f v4l2 -framerate 30 -video_size "$video_res" -input_format "${video_fmt}" -i "$video_dev" \
       -f pulse -i "${SRC_mic}" -ar 44100 -c:a aac -b:a 320k \
       -c:v libx264 -preset:v slow -crf:v 23 -g 25 -pix_fmt yuv420p -movflags +faststart \
       -bufsize 2M -rtbufsize 2M  \
       -map 0:v "${OUT_VIDEO}"      \
       -map 1:a "${OUT_VOCAL}" &
ff_pid=$! 

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
yt-dlp "${video_url}" -o "${REC_DIR}/$filename" --format 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --no-check-certificates --console-title --quiet --default-search "ytsearch: karaoke Lyrics --match-filter duration < 300"
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
colorecho "yellow" "Playback length: ${PLAYBACK_LEN}";
ffmpeg -y -hide_banner -loglevel error "$filename" "$PLAYBACK_BETA";

else
    colorecho "red" "No suitable playback file found."
        # Get the PID of the parent process
        parent_pid=$$
        # Call the function to kill the parent process and all its children
        kill_parent_and_children $parent_pid
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
    exit;
fi

rm -rf "${OUT_DIR}"/"${karaoke_name}"_*.*;
# Let's Record with webcam  then Post-production
ext_recz="mp4"
OUT_VIDEO="${OUT_DIR}"/"${karaoke_name}"_out."${ext_recz}";
OUT_VOCAL="${OUT_DIR}"/"${karaoke_name}"_out.wav;
VOCAL_FILE="${OUT_DIR}"/"${karaoke_name}"_enhance.wav;
	
colorecho "SING!---Launching webcam;";
colorecho "blue" "Using video device: $video_dev";
colorecho "yellow" "Using audio source: ${SRC_mic}";

colorecho "cyan" "WILL try to enable overlay if available in this webcam, to monitor recording";

v4l2-clt --overlay 1;
launch_ffmpeg_webcam true;

epoch_ff=$( get_process_start_time );
renice -n -19 "$ff_pid"
    colorecho "green" "FFmpeg start Epoch: $epoch_ff";
    
# Wait for the output file to be created
while [ ! -s "${OUT_VIDEO}" ]; do
  sleep 0.001; # Adjust sleep time as needed
done | zenity --progress --text="GET READY TO SING" \
              --title="Starting to tape!" --width=440 --height=400 --percentage=50 --pulsate --auto-close --auto-kill

colorecho "yellow" "Launch lyrics video";

	        ffplay -left +0 \
                        -top +0 \
			        -window_title "SING" -loglevel quiet -hide_banner \
                    -af "volume=0.15" \
                    -noborder -exitonkeydown  \
                    -vf "scale=848:480" "${PLAYBACK_BETA}" &
            ffplay_pid=$!;
            epoch_ffplay=$( get_process_start_time  );

    colorecho "red" "ffplay start E: $epoch_ffplay";
        diff_ss="$(time_diff_seconds "${epoch_ff}" "${epoch_ffplay}")"
        colorecho "magenta" "diff_ss: $diff_ss"; # try to compensate if out of sync brutally

cronos_play=1 ### RECORDING PROGRESS! If FFmpeg or playback quits, or clicking cancel, recording stops
while [ "$(printf "%.0f" "${cronos_play}")" -le "$(printf "%.0f" "${PLAYBACK_LEN}")" ]; do
    sleep 1
        if [ "$cronos_play" -le 3 ]; then
            xdotool search --name "Recording" windowactivate
        fi
    cronos_play=$(( "$cronos_play" + 1 ));
    # shellcheck disable=SC2005
    echo $(( ("$cronos_play"*100) / "$PLAYBACK_LEN" ))
            # Check if the webcam process is still running
            if ! ps -p "$ff_pid" >/dev/null 2>&1; then
                break
            fi
            # Check if the player process is still running
            if ! ps -p "$ffplay_pid" >/dev/null 2>&1; then
                break
            fi
done | zenity --progress --text="Pressing will STOP recorder and start render post-production MP4" \
              --title="Recording" --width=640 --height=200 --percentage=0 

# Check if the progress dialog was canceled OR completed
if [ $? = 1 ]; then
    colorecho "red" "Recording skipped.";
else
    colorecho "cyan" "Progress completed.";
fi


colorecho "blue" "Actual playback duration: ${PLAYBACK_LEN}";
colorecho "red" "Calculated diff sync: $diff_ss";

# give 5sec for recorder graceful finish, just in case :P
    colorecho "magenta" "Recorded!";
            killall -SIGTERM ffmpeg;
            killall -9 ffplay;
             # disable loopback monitor and cam overlay
            pactl unload-module module-loopback;
            v4l2-ctl --overlay 0;
    sleep 5;        
   
##POSTprod filtering
colorecho "yellow" "[AuDIO] Apply shibata dithering with SoX, also noise reduction...";
#ffmpeg -y -hide_banner -loglevel error -i "${OUT_VIDEO}" "${VOCAL_FILE}";
sox "${OUT_VOCAL}" -n trim 0 5 noiseprof "$OUT_DIR"/"$karaoke_name".prof;
sox "${OUT_VOCAL}" "${VOCAL_FILE}" \
    noisered "$OUT_DIR"/"$karaoke_name".prof 0.2 \
                            dither -s -f shibata;

colorecho "yellow" "[AuDIO] Apply vocal tuning algorithm Gareus XC42...";
lv2file -i "${VOCAL_FILE}" -o "${OUT_VOCAL}" \
    -P Live \
    -p mode:Auto  \
    http://gareus.org/oss/lv2/fat1

colorecho "yellow" "[AuDIO] Apply vocal tuning algorithm Auburn Sound's Graillon...";
lv2file -o "${VOCAL_FILE}" -i "${OUT_VOCAL}" \
    -P Younger\ Speech \
    -p p9:1.00 -p p20:2.00 -p p15:0.515 -p p17:1.000 -p p18:1.00 \
    https://www.auburnsounds.com/products/Graillon.html40733132#in1out2

colorecho "red" "[Audio and Video] PostProduction: rendering mix with enhancements."
export LC_ALL=C;  
OUT_FILE="${OUT_DIR}"/"${karaoke_name}"_beta.mp4;
#-ss "$( printf "%0.8f" "$( echo "scale=8; ${diff_ss} * -1 " | bc )" )"  -i "${OUT_VIDEO}" \

ffmpeg -y  -loglevel error -hide_banner -stats -stats_period 5s   \
                                            -i "${PLAYBACK_BETA}" \
    -ss "$( printf "%0.8f" "$( echo "scale=8; ${diff_ss}/2  " | bc )" )" -i "${VOCAL_FILE}" \
    -filter_complex "
      [0:a]volume=volume=0.35,
    aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[playback];

      [1:a]
    adeclip,compensationdelay,alimiter,speechnorm,acompressor,
    aecho=0.8:0.8:56:0.33,treble=g=4,
        aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,
        aresample=resampler=soxr:osf=s16:precision=33[vocals];

    [playback][vocals]amix=inputs=2:weights=0.45|0.56;

    waveform,scale=s=640x360[v1];
    gradients=n=7:s=640x360,format=rgba[vscope];
        [0:v]scale=s=640x360[v0];
        [v1][vscope]xstack=inputs=2,scale=s=640x360[badcoffee];
        [v0][badcoffee]vstack=inputs=2,scale=s=640x480;" \
            -t "${PLAYBACK_LEN}" \
     -c:v libx264 -b:v 10000k -movflags faststart \
       -c:a aac -b:a 250k -ar 44100  \
         "${OUT_FILE}" &
           ff_pid=$!;

    render_display_progress "${OUT_FILE}" $ff_pid;

colorecho "green" "[BETAKê] Done. Merging final output!" 
    
    FINAL_FILE="${OUT_FILE%.*}"ke.mp4
    
        ffmpeg  -loglevel error -hide_banner -stats -stats_period 5s  \
                                                            -i "${OUT_FILE}" \
        -ss "$( printf "%0.8f" "$( echo "scale=8; ${diff_ss} " | bc )" )" \
                                                            -i "${OUT_VIDEO}" \
            -filter_complex "[0:v]scale=s=${video_res}[vidres];
                             [vidres][1:v]xstack=inputs=2,
                             drawtext=fontfile=OpenSans-Regular.ttf:text='%{eif\:$PLAYBACK_LEN-t\:d}':fontcolor=white:fontsize=24:x=w-tw-20:y=th:box=1:boxcolor=black@0.5:boxborderw=10;" \
                              -s 1920x1080 "${FINAL_FILE}" &
                ff_pid=$!;

        render_display_progress "${FINAL_FILE}" $ff_pid;

colorecho "yellow" "Generating MP3 too ou outputs dir..";
generate_mp3 "${FINAL_FILE}" "${OUT_FILE%.*}".mp3;

# display resulting video to user    
ffplay  -loglevel error -hide_banner -window_title "Obrigado pela participação! sync diff: ${diff_ss}" "${FINAL_FILE}";

colorecho "green" "Thank you for having fun!"
exit;
