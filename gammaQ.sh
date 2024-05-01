#!/bin/bash

# Function to check if input is within certain range ( between $2 and $3 )
check_range() {
    if (( $(echo "$1 < $2 || $1 > $3 " | bc -l) )); then
        return 1
    else
        return 0
    fi
}

# function to display colored msgs, also only these show on python console
#the rest of verbose output lies on script.log ( TAIL LOGS button )

colorecho() {
    color=$1;
    message=$2;

    if [ "${color}" == "" ]; then
        color="green";
        
    fi

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
        *) message="$1"; coding="\e[37m" ;;
    esac
    echo -e "${coding}${message}🎼\e[0m";
}

colorecho "Welcome!";

# Function to kill the parent process and all its children
    kill_parent_and_children() {
        local parent_pid=$1
        local child_pids;
        child_pids=$(pgrep -P "$parent_pid")
                    
                    colorecho "white" "disable audio loopback monitor"
                    pactl unload-module module-loopback;
                    ##pactl unload-module module-echo-cancel;

        # Kill the parent process and all its children
        echo "Killing parent process $parent_pid and its children: $child_pids"
        kill -9 "$parent_pid" "$child_pids"

        # Check if the processes are still running
        for pid in $parent_pid $child_pids; do
            if ps -p "$pid" > /dev/null; then
                colorecho "red" "Process $pid is still running"
            else
                echo "Process $pid has been terminated"
            fi
        done
    }

#function is_stereo() {
  # Get the filename passed as an argument
#  file="$1"

  # Check if ffprobe exists
#  if ! command -v ffprobe &> /dev/null; then
#    echo "Error: ffprobe is not installed. Please install ffprobe."
#    return 1
#  fi

  # Use ffprobe to get audio stream information
#  channels=$(ffprobe -show_format -show_streams -print_format json "$file" 2>/dev/null | jq -r '.streams[].channels')

  # Check the number of channels
#  if [[ "$channels" -gt 1 ]]; then
#    return 0
#  else
#    return 1
#  fi
#}


#function to sanitize when it's expected a number input
ensure_number_type() {
    local input="$1"
    # Check if it's a number
    if [[ "$input" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        # Check if it's a float
        if [[ "$input" =~ \. ]]; then
            echo "$input"
        else
            echo "$input"
        fi
    else
        echo "1"
    fi
}

# function to render a nice progress bar for FFMpeg
render_display_progress() {
    local total_duration="${PLAYBACK_LEN}"  # Total duration of the video in seconds
    local pid_ffmpeg="$2"     # PID of the ffmpeg process

    # Create a dialog box with a progress bar
    (
    while true; do
        sleep 2.5;
        # Check if the ffmpeg process is still running
        if ! ps -p "$pid_ffmpeg" >/dev/null 2>&1; then
            break
        fi

        local current_duration;
        local progress;

        # Extract the last occurrence of the time string from the log file
        time_string=$(grep -oE 'time=[0-9:.]*' "$LOG_FILE" | tail -n1)
        # Extract the time part from the time string
        time_value=${time_string##time=}
        # Extract the time part without milliseconds
        time_without_ms=$(echo "$time_value" | awk -F'.' '{print $1}')
        
        # Convert time without milliseconds to seconds, trim leading zeroes
        hours=$(echo "$time_without_ms" | cut -d':' -f1 | sed 's/^0*//')
        minutes=$(echo "$time_without_ms" | cut -d':' -f2 | sed 's/^0*//')
        seconds=$(echo "$time_without_ms" | cut -d':' -f3 | sed 's/^0*//')
        # Convert hours, minutes, and seconds to seconds
        current_duration=$(( (hours * 3600) + (minutes * 60) + seconds ))

        # Calculate the percentage of completion based on the current duration already rendered
        progress=$( printf "%.0f" "$(echo "scale=4; ($current_duration / $total_duration) * 100" | bc)" );
        echo "$progress";

    done
    ) | zenity --progress --title="Rendering" --text="Rendering in progress...please wait" --percentage=0 --auto-close

}

# function to test media file format
check_validity() {
    local filename;
    filename="${1}";
    
    # Check if the file exists
    if [ ! -f "$filename" ]; then
        colorecho "$filename : File not found!"
        kill_parent_and_children $$
        exit
    fi

    # Use ffprobe to check if the file is a valid MP4
    if ffprobe -v error -show_entries format=format_name -of default=noprint_wrappers=1:nokey=1 "$filename" 2>/dev/null | grep -q "${2}"; then
        colorecho "green" "The file '$filename' is a valid ${2}"
    else
        colorecho "red" "The file '$filename' is not a valid ${2}"
        kill_parent_and_children $$
        exit
    fi
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

# function to return in FFMpeg videos format
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

# Define the function to calculate dB difference between playback and vocals track
calculate_db_difference() {
    # Extract RMS amplitude from each file
    RMS1="$1";
    RMS2="$2";
    # Calculate dB difference and increase a little the result
    dB_difference=$(awk -v RMS1="$RMS1" -v RMS2="$RMS2" 'BEGIN { print 20 * log(RMS1 / RMS2) / log(10) }');
    # Print the result
    echo "$dB_difference";
}


# Define the function to adjust vocals to match playback volume, auto adj vol feature
adjust_vocals_volume() {
    # Define the fixed target volume level
    target_volume="-16"
    # Extract RMS amplitude from each file
    RMS_playback="$1"
    RMS_vocals="$2"

    # Calculate dB difference between vocals and playback
    dB_difference=$( calculate_db_difference "$RMS_playback" "$RMS_vocals" );

  # Calculate the adjustment needed for the vocals as a multiplier
    adjustment_percentage=$(awk -v target="$target_volume" -v diff="$dB_difference" 'BEGIN { print (10^(target/20 - diff/20) * 100)  }')
    # Print the adjustment needed as a multiplier
    echo "$adjustment_percentage"
}


cfg_audio() {
 # we use just to cfg audio for FFMpeg
        RATE_mic="$(pactl list sources short | grep "${SRC_mic}" |  awk '{ print $6 }' | sed 's/[[:alpha:]]//g' )"
        CH_mic="$(pactl list sources short | grep "${SRC_mic}" |  awk '{ print $5 }' | sed 's/[[:alpha:]]//g' )"
        BITS_mic="$(pactl list sources short | grep "${SRC_mic}" |  awk '{ print $4 }' | sed 's/float/f/g' )"
        if pactl list sources short | grep "${SRC_mic}" |  awk '{ print $4 }' | grep -q float; then
            ENC_mic="floating-point";
        else
            if pactl list sources short | grep "${SRC_mic}" |  awk '{ print $4 }' | grep -q u; then
                ENC_mic="unsigned-integer";
            else
                ENC_mic="signed-integer";
            fi
       fi
}

# the webcam recorder and pulse/pipewire audio recorder
# with laggy preview of video
launch_ffmpeg_webcam() {

best_format=$(v4l2-ctl --list-formats-ext -d "${video_dev}" | grep -e '\[[0-9]\]' | awk '{ print $2 " " $3 }' | sort -k2 -n | tail -n1 | awk '{ print $1 }')
video_res=$(v4l2-ctl --list-formats-ext -d "${video_dev}" | \
                           awk -v fmt="${best_format}" '$0 ~ fmt {f=1} f && /Size/ {print $3; f=1}' | \
                           sort -k1 -n | tail -n1 );
video_fmt=$(translate_vid_format "${best_format}")

cfg_audio true

colorecho "green" "FFmpeg format name: ${video_fmt}";
colorecho "cyan" "Best resolution: ${video_res}";
colorecho "green" "params Audio: ${CH_mic}ch ${BITS_mic}bits ${RATE_mic}Hz ${ENC_mic}";

if ffmpeg -loglevel info  -hide_banner -f v4l2 -video_size "$video_res" -input_format "${video_fmt}" -i "$video_dev" \
        -f pulse -ar "${RATE_mic}" -ac "${CH_mic}" -c:a pcm_"${BITS_mic}"  -i "${SRC_mic}" \
         -c:v libx264 -preset:v ultrafast -crf:v 23 -pix_fmt yuv420p -movflags +faststart \
       -map 0:v "${OUT_VIDEO}"  \
       -map 1:a   "${OUT_VOCAL}" \
    -map 0:v -vf "format=yuv420p" -c:v rawvideo -f nut - | mplayer -really-quiet -noconsolecontrols -nomouseinput -hardframedrop -framedrop -x 640 -y 400 -nosound - &
                    ff_pid=$!; then
       colorecho "cyan" "Success: ffmpeg process";
else
       colorecho "red" "FAIL ffmpeg process";
       kill_parent_and_children $$
       exit
fi
}

colorecho "green" "This is deltaQ° ŧħ3 B3TAKê ·v4· by https://gu.pro.br ®";
SCREEN_WIDTH=$(xdpyinfo | grep dimensions | awk '{print $2}' | cut -d 'x' -f1)
SCREEN_HEIGHT=$(xdpyinfo | grep dimensions | awk '{print $2}' | cut -d 'x' -f2)

karaoke_name="$1";
video_url="$2";
betake_path="$3";
video_dev="$4";
overlay_url="$5";

if [ "${karaoke_name}" == "" ]; then karaoke_name="BETA"; fi
if [ "${video_url}" == "" ]; then video_url=" --simulate "; fi
if [ "${betake_path}" == "" ]; then betake_path="$(pwd)"; fi
if [ "${video_dev}" == "" ]; then video_dev="/dev/video0"; fi

# Configuration
REC_DIR="$betake_path/playbacks"   # Directory to store downloaded playbacks
OUT_DIR="$betake_path/outputs"      # Directory to store output files
OVER_DIR="$betake_path/overlays"      # Directory to store optional overlay files

    cd "${betake_path}" || exit;

    mkdir -p "$REC_DIR" || exit;
    mkdir -p "$OUT_DIR" || exit; 
    mkdir -p "$OVER_DIR" || exit;

##########################################################################################################################
# Define log file path 
LOG_FILE="$betake_path/script.log"
#*******************************************************
# Load configuration variables and adj volumes #########
SINK="$( pactl get-default-sink )"
colorecho "yellow" " got sink: $SINK";
SRC_mic="$( pactl get-default-source )"
colorecho "green" " got mic src: $SRC_mic";
########################################################
colorecho "white" "Loopback monitor audio ON";
pactl unload-module module-loopback;
pactl load-module module-loopback source="${SRC_mic}" sink="${SINK}" & 

##DOWNLOAD PLAYBACK

colorecho "white" "fetch the video title (more logs on TAIL LOGS button)";
PLAYBACK_TITLE="$(yt-dlp --get-title "${video_url}" --no-check-certificates --enable-file-urls --no-playlist)";
colorecho "magenta" "Found video: ${PLAYBACK_TITLE}";
colorecho "red" "${video_url}";

export LC_ALL=C;
if [[ "${video_url}" == file://* ]]; then
    filename="${video_url#file://}";
else     
    # Download the video, it will remain in cache
    dl_name=$(yt-dlp "${video_url}" --get-filename --format 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --no-check-certificates --no-playlist);
    yt-dlp -o "${dl_name}" "${video_url}" -P "${REC_DIR}" --format 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' \
         --no-check-certificates --no-overwrites --no-playlist;
    # perphaps convert
    filename="${REC_DIR}"/"${dl_name}";
fi
PLAYBACK_BETA="${filename%.*}".mp4;

# Check if a file was found
if [ -n "$filename" ]; then
    colorecho "blue" "Using file: $filename"
    # Extracting the extension
    extension=$(basename "$filename" | awk -F . '{print $NF}')
    colorecho "green" "Extension of the file is: $extension"
    # Get total duration of the video and cast to integer
    PLAYBACK_LEN=$( echo "scale=0; $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${filename}")/1" | bc ); 
    colorecho "yellow" "Playback length: ${PLAYBACK_LEN}";
    # Checking if the extension is not "mp4" (case-insensitive)
    if [[ ! "$extension" =~ ^mp4$ ]]; then
        colorecho "red" "The file is not an MP4 file. will convert;"
        ffmpeg -y -hide_banner -loglevel info  "$filename" "$PLAYBACK_BETA";
            ff_pid=$!;
        render_display_progress "${PLAYBACK_BETA}" "${ff_pid}";
    else
        colorecho "cyan" "The file is an MP4 file already.";
    fi
else 
    colorecho "red" "No suitable playback file found.";
        # Get the PID of the parent process
        parent_pid=$$
        # Call the function to kill the parent process and all its children
        kill_parent_and_children $parent_pid
    exit;
fi
check_validity "${PLAYBACK_BETA}" "mp4";

if [ "$overlay_url" != "" ]; then
colorecho "magenta" "Download overlay video as requested"
    if [[ "${overlay_url}" == file://* ]]; then
        OVERLAY_BETA="${overlay_url#file://}";
    else
# Download the overlay, it will remain in cache
        dl_name=$(yt-dlp "${overlay_url}" --get-filename --format 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --no-check-certificates --no-playlist);
        yt-dlp -o "${dl_name}" "${overlay_url}" -P "${OVER_DIR}" --format 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' \
         --no-check-certificates --no-overwrites --no-playlist;
        OVERLAY_BETA="${OVER_DIR}"/"${dl_name}";
    fi
fi

OUT_VIDEO="${OUT_DIR}"/"${karaoke_name}"_out.mp4;
OUT_VOCAL="${OUT_DIR}"/"${karaoke_name}"_out.wav;
VOCAL_FILE="${OUT_DIR}"/"${karaoke_name}"_enhance.wav;
VOCAL_ORIG="${OUT_DIR}"/"${karaoke_name}"_orig.wav;

if [ "$6" -ne 1 ]; then
    colorecho "cyan" "All setup to sing!";
    # Display message to start webcam capture
    export LC_ALL=C;
    zenity --question --text=" - - Let's sing? " --title "Accept song or abort" --ok-label="SING";
    if [ $? == 1 ]; then
        colorecho "red" "Performance aborted.";
        # Get the PID of the parent process
        parent_pid=$$
        # Call the function to kill the parent process and all its children
        kill_parent_and_children $parent_pid
        exit;
    fi

    rm -rf "${OUT_DIR}"/"${karaoke_name}"_*.*;

    colorecho "Let's Record with webcam and pulseaudio/pipewire default source"
    colorecho "SING!---Launching webcam;";
    colorecho "magenta" "Using video device: $video_dev";
    colorecho "magenta" "Using audio source: ${SRC_mic}";

    # launch webcam recorder
    launch_ffmpeg_webcam true;
    epoch_ff=$( get_process_start_time );
    renice -n -19 "$ff_pid"
    colorecho "red" "RECORDER start Epoch: $epoch_ff";

    # Wait for the output file to be created and not empty; only then we run ffplay
    while [ ! -s "${OUT_VIDEO}" ]; do
        sleep 0.0001; # Adjust sleep time as needed
    done | zenity --progress --text="GET RDY TO SING" \
              --title="Starting playback NOW" --percentage=50 --pulsate --auto-close --auto-kill

    colorecho "yellow" "Launch lyrics video";

	        ffplay \
			        -window_title "SING" -loglevel quiet -hide_banner \
                    -vf "scale=1024x768" "${PLAYBACK_BETA}" &
            ffplay_pid=$!;
            epoch_ffplay=$( get_process_start_time  );

    colorecho "red" "ffplay start Epoch: $epoch_ffplay";
        diff_ss="$(time_diff_seconds "${epoch_ff}" "${epoch_ffplay}")"
        echo "${diff_ss}" > "${OUT_DIR}"/"${karaoke_name}".diff_ss;
        colorecho "magenta" "diff_ss: $diff_ss"; # will try to adj sync brutally when rendering

    cronos_play=1 
    wmctrl -r "SING" -e 0,-$(( 1024+(SCREEN_WIDTH/2) )),$(( SCREEN_HEIGHT+768 )),-1,-1
    ### RECORDING PROGRESS! 
    # If FFmpeg or FFplayback quits, or if click cancel, webcam capture stops
    while [ "$(printf "%.0f" "${cronos_play}")" -le "$(printf "%.0f" "${PLAYBACK_LEN}")" ]; do
        sleep 1;

        wmctrl -r "MPlayer" -b add,above 
        wmctrl -r "Recording" -b add,above 
        wmctrl -r "Recording" -e -1,-1,0,0,0
    
        cronos_play=$(( "$cronos_play" + 1 ));
        # shellcheck disable=SC2005
        echo $(( ("$cronos_play"*100) / "$PLAYBACK_LEN" ))
            # Check if the webcam recorder process is still running
            if ! ps -p "$ff_pid" >/dev/null 2>&1; then
                break
            fi
            # Check if the playback process is still running
            if ! ps -p "$ffplay_pid" >/dev/null 2>&1; then
                break
            fi
    done | zenity --progress --text="Press to STOP performing and render MP4" \
              --title="Recording" --percentage=0 --auto-close

else
    diff_ss=$( cat "${OUT_DIR}"/"${karaoke_name}".diff_ss );
fi

# Check if the progress dialog was canceled OR completed
if [ $? = 1 ]; then
    colorecho "white" "Recording skipped before end of playback. Will render MP4!";
else
    colorecho "blue" "Entire Progress completed. Will render MP4!";
fi

colorecho "cyan" "Actual playback duration: ${PLAYBACK_LEN}";
colorecho "magenta" "Calculated diff sync: $diff_ss";

# give 3 sec for recorder graceful finish, just in case :P
    colorecho "magenta" "Performance Recorded!";
            killall -SIGTERM ffmpeg;
            killall -9 ffplay;
            killall -9 mplayer;
            #killall -SIGINT sox;

            colorecho "white" "disable audio loopback monitor"
            pactl unload-module module-loopback;

    sleep 3;

   check_validity "${OUT_VIDEO}" "mp4";
   check_validity "${OUT_VOCAL}" "wav";

   # make a bkp if needed to restore later without enhancements
   cp -ra "${OUT_VOCAL}" "${VOCAL_ORIG}";

zenity --question --text=" - - Render video and MP3? " --title "Proceed, or abort production??" --ok-label="RENDER, yes";
if [ $? == 1 ]; then
    colorecho "red" "Production aborted.";
    # Get the PID of the parent process
    parent_pid=$$
    # Call the function to kill the parent process and all its children
    kill_parent_and_children $parent_pid
    exit;
fi

# Restore original for post-prod
cp -ra "${VOCAL_ORIG}" "${OUT_VOCAL}";

### START enhancements
cp -ra "${OUT_VOCAL}" "${VOCAL_FILE}";
colorecho "yellow" "DEclip..";
lv2file -i "${VOCAL_FILE}" -o "${OUT_VOCAL}"  \
     http://plugin.org.uk/swh-plugins/declip > lv2.tmp.log 2>&1
    colorecho "white" "$( cat lv2.tmp.log )";
    check_validity "${OUT_VOCAL}" "wav";
    rm -f lv2.tmp.log;

colorecho "yellow" "Apply dithering & noise reduction with SoX";
sox "${OUT_VOCAL}" -n trim 0 5 noiseprof "$OUT_DIR"/"$karaoke_name".prof > lv2.tmp.log 2>&1
    colorecho "white" "$( cat lv2.tmp.log )";
sox "${OUT_VOCAL}" "${VOCAL_FILE}" \
    noisered "$OUT_DIR"/"$karaoke_name".prof 0.1 \
                            dither -s > lv2.tmp.log 2>&1
    colorecho "white" "$( cat lv2.tmp.log )";
check_validity "${VOCAL_FILE}" "wav";

colorecho "yellow" "Execute vocal tuning algorithm Gareus XC42...";
lv2file -i "${VOCAL_FILE}" -o "${OUT_VOCAL}"  \
    -P Live \
    -p mode:Auto \
     http://gareus.org/oss/lv2/fat1 > lv2.tmp.log 2>&1
    
    colorecho "white" "$( cat lv2.tmp.log )";
    check_validity "${OUT_VOCAL}" "wav";
    rm -f lv2.tmp.log;

colorecho "magenta" "Calculate volume discrepancy between vocals and playback";
ffmpeg -hide_banner -y -i "${PLAYBACK_BETA}" "${PLAYBACK_BETA%.*}".wav; #sox cant work with mp4
                         check_validity "${PLAYBACK_BETA%.*}".wav "wav";
# Extract volume info and calc adj in dB by comparing each file RMS
PLAYBACK_dBs="$( sox "${PLAYBACK_BETA%.*}".wav -n stat 2>&1 | grep -e 'RMS.*amplitude' | awk '{ print $3}' )";
VOCALS_dBs="$( sox "${OUT_VOCAL}" -n stat 2>&1 | grep -e 'RMS.*amplitude' | awk '{ print $3}' )";
DB_diff=$( adjust_vocals_volume "${PLAYBACK_dBs}" "${VOCALS_dBs}" | sed 's/[[:alpha:]]//g');
 DB_diff=$( ensure_number_type "${DB_diff}");
DB_diff=$(printf "%0.0f" "$(echo "scale=0; ${DB_diff} * 100 " | bc)"); # transform in % notation

colorecho "red" "Recommend a calculated base adjustment of: ${DB_diff} % ";
                        rm -rf "${PLAYBACK_BETA%.*}".wav;

while true; do
    VALUE=$(zenity --scale --text="Select vocals Boost % (max 10x) (min = vocals silence)" --min-value="0" --max-value="10000" --step="1" --cancel-label="No adj" --value="${DB_diff}" )

    case $? in
         0)
            selection=${VALUE};;
         1)
            selection="100";;
        -1)
            selection="100";;
    esac

# Check if selection is within range
    if check_range "$selection" "0" "10000"; then
    # Prompt user for action
        if zenity --question --title="Preview or Confirm" --text="Do you want to preview the VOL adj of ${selection}% ?" --ok-label="Preview please" --cancel-label="RENDER NOW"; then
# User chose Preview
           DB_diff_preview=$(printf "%0.8f" "$(echo "scale=8;  ${selection}/100" | bc)")

           ffmpeg -y  -loglevel info -hide_banner \
                                                                      -i "${PLAYBACK_BETA}" \
    -ss "$( printf "%0.8f" "$( echo "scale=8; ${diff_ss} " | bc )" )" -i "${OUT_VOCAL}" \
    -filter_complex "  
    [0:a]equalizer=f=50:width_type=q:width=2:g=10[playback];
    [1:a]afftdn=nr=11:gs=50:ad=0:tn=1:tr=1,volume=volume=${DB_diff_preview},alimiter,speechnorm,
    aecho=0.89:0.89:84:0.21,treble=g=5,deesser=i=1:f=0:m=1,
    rubberband=tempo=1.0:pitch=1.0:transients=smooth:detector=soft:phase=independent:window=long:smoothing=on:formant=preserved:pitchq=quality:channels=apart,
    acompressor=mode=upward,aexciter[vocals];
    [playback][vocals]amix=inputs=2:weights=0.69|0.90[betamix];" \
      -map "[betamix]" "${OUT_VOCAL%.*}"_tmp.wav &
       ff_pid=$!; 
       
       render_display_progress "${OUT_VOCAL%.*}"_tmp.wav $ff_pid;
        check_validity "${OUT_VOCAL%.*}"_tmp.wav "wav";

           totem "${OUT_VOCAL%.*}"_tmp.wav &
            ffplay_pid=$!
           zenity --info --title "Preview vocals" --text "Multiplier factor would be: ${DB_diff_preview}x Press ok to STOP preview."
           kill -9 $ffplay_pid
        else
 # User chose Confirm
            THRESH_vol="${selection}";
            break
        fi
    else
        # Selection out of range, show warning and repeat dialog
       zenity --error --title "Warning" --text "Input must be between 0% and 10000% -- Please try again."
   fi
done

colorecho "magenta" "Selected threshold volume: ${THRESH_vol}%"

    DB_diff="$( printf "%0.8f" "$( echo "scale=8; ${THRESH_vol}/100" | bc )" )" 
    
    colorecho "green" "tuning vocals volume"
   ffmpeg -y -i "${OUT_VOCAL}" -af "afftdn=nr=11:gs=50:ad=0:tn=1:tr=1,volume=volume=${DB_diff},alimiter,speechnorm,
    aecho=0.89:0.89:84:0.21,treble=g=5,deesser=i=1:f=0:m=1,
    rubberband=tempo=1.0:pitch=1.0:transients=smooth:detector=soft:phase=independent:window=long:smoothing=on:formant=preserved:pitchq=quality:channels=apart,
    acompressor=mode=upward" "${VOCAL_FILE}" &
        ff_pid=$!;

         render_display_progress "${VOCAL_FILE}" $ff_pid;
         colorecho "yellow" " $DB_diff applied to vocals volume;"
        check_validity "${VOCAL_FILE}" "wav";

colorecho "blue" "now will mix playback and vocals enhanced"
OUT_FILE="${OUT_DIR}"/"${karaoke_name}"_beta.mp4;
seedy=",hue=h=7*PI*t/$(fortune|wc -l):s=1";
if [ "${OVERLAY_BETA}" == "" ]; then
    OVERLAY_BETA="xut.png";
fi

 if ffmpeg -y  -loglevel info -hide_banner \
    -ss "$( printf "%0.8f" "$( echo "scale=8; ${diff_ss} * 1 " | bc )" )" -i "${VOCAL_FILE}" \
    -ss "$( printf "%0.8f" "$( echo "scale=8; ${diff_ss} * 2 " | bc )" )" -i "${OUT_VIDEO}" \
    -i "${PLAYBACK_BETA}" -i "${OVERLAY_BETA}" \
    -filter_complex "  
    [2:a]equalizer=f=50:width_type=q:width=2:g=8[playback];
    [0:a]aexciter[vocals];
    [playback][vocals]amix=inputs=2:weights=0.69|0.90[betamix];
        gradients=n=6:s=640x400[vscope];
        [2:v]scale=640x400[v2];
        [v2][vscope]vstack,scale=640x400[hugh];
        [1:v]scale=640x400 $seedy [yikes];
        [3:v]trim=duration=${PLAYBACK_LEN},scale=640x400,format=rgba,colorchannelmixer=aa=0.45[yeah];
        [yikes][yeah]overlay[hutz];
        [hutz][hugh]xstack,
        drawtext=fontfile=Ubuntu-B.ttf:text='%{eif\:${PLAYBACK_LEN}-t\:d}':
        fontcolor=yellow:fontsize=48:x=w-tw-20:y=th:box=1:boxcolor=black@0.5:boxborderw=10[visuals];" \
        -s 1920x1080 -t "${PLAYBACK_LEN}" \
            -r 30 -c:v libx264 -movflags faststart -preset:v ultrafast \
            -c:a aac -map "[betamix]" -map "[visuals]" -f mp4 "${OUT_FILE}" &
                             ff_pid=$!; then
                colorecho "cyan" "Started render ffmpeg process";
else
       colorecho "red" "FAIL to start ffmpeg process";
       kill_parent_and_children $$
       exit
fi 
                
    render_display_progress "${OUT_FILE}" $ff_pid;
    check_validity "${OUT_FILE}" "mp4";

zenity --info --text="Video render DONE" --title "Success" --timeout=6;


if ffmpeg -hide_banner -loglevel error -y -i "${OUT_FILE}" "${OUT_FILE%.*}".mp3; then
    colorecho "cyan" "MP3 rendered OK"
else
    colorecho "red" "Failed to render MP3. This is not a fatal error.";
fi

zenity --warning --text="Let's watch your performance video now: ${OUT_FILE}" --title "Ready to watch" --timeout=15;

# display resulting video to user    
mplayer "${OUT_FILE}";

colorecho "cyan" "Thank you for having fun!"
exit;
