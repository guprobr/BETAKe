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
    echo -e "\e93m[[[[RESTARTING]]]]  audio server now:\e[0m";
    killall -HUP pipewire-pulse
    sleep 1; 
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
# Function to get total number of frames
get_total_frames() {
    total_frames=$(ffmpeg -i "${1}" 2>&1 | grep "Duration" | awk '{print $2}' | tr -d ',')
    hours=$(echo "$total_frames" | cut -d':' -f1)
    minutes=$(echo "$total_frames" | cut -d':' -f2)
    seconds=$(echo "$total_frames" | cut -d':' -f3 | cut -d'.' -f1)
    total_seconds=$((hours * 3600 + minutes * 60 + seconds))
    framerate=$(ffmpeg -i "${1}" 2>&1 | grep -oP ', \K[0-9]+ fps' | awk '{print $1}')
    total_frames=$(echo "$total_seconds * $framerate" | bc)
    echo "$total_frames"
}

 # Function to get the duration of the video
    get_video_duration() {
        duration=$(ffmpeg -i "${1}" 2>&1 | grep "Duration" | awk '{print $2}' | tr -d ',')
        hours=$(echo "$duration" | cut -d':' -f1)
        minutes=$(echo "$duration" | cut -d':' -f2)
        seconds=$(echo "$duration" | cut -d':' -f3 | cut -d'.' -f1)
        total_seconds=$((hours * 3600 + minutes * 60 + seconds))
        echo "$total_seconds"
    }

# Function to display progress using estimated file size
    render_display_progress() {
        local video_bitrate=2000  # Example video bitrate in kbps
        local audio_bitrate=128   # Example audio bitrate in kbps
        local duration_seconds=3600  # Example duration in seconds
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
        local total_size_mb=$(echo "scale=2; $total_size_bytes / (1024 * 1024)" | bc)

        # Create a dialog box with a progress bar
        (
        while true; do
            # Check if the ffmpeg process is still running
            if ! ps -p "$ff_pid" >/dev/null 2>&1; then
                break
            fi

            # Calculate the percentage of completion based on the file size
            local current_file_size=$(stat -c%s "${1}" )
            local progress=$(echo "scale=3; ($current_file_size * 100) / $total_size_bytes" | bc)

            # Update the progress bar in the dialog
            echo "$progress"

            sleep 0.1
        done
        ) | zenity --progress --title="Video Rendering !" --text="Rendering in progress...please wait" --auto-close --auto-kill
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
SINKa="beta_mic"
SINKb="beta_ladspa"
SINKc="$( pactl get-default-sink )"
SRC_mic="$( pactl get-default-source )"
echo -e "\e[93m*HOUSEKEEPING SOUND SERVERS*\e[0m";
echo -e "\e[91mINIT MIC\"SINK A\"\e[0m";
echo -e "\e[93mLoading module-remap-source for microphone sink\e[0m";
pactl load-module module-remap-source source_name="${SINKa}" source_master="${SRC_mic}";

echo -e "\e[91maAjustar vol ${SRC_mic} em 33%";
 pactl set-source-volume "${SRC_mic}" 33%;
echo -e "\e[91maAjustar vol ${SINKa} USE HEADPHONES\e[0m";
 pactl set-source-volume "${SINKa}" 90%;
echo -e "\e[94maAjustar vol ${SINKb} 90%\e[0m";
 pactl set-sink-volume "${SINKb}" 90%;
echo -e "\e[91maAjustar vol ${SINKb}.monitor 90%\e[0m";
 pactl set-source-volume "${SINKb}".monitor 90%;
echo -e "\e[92maAjustar vol ${SINKc} 50%..\e[0m";
 pactl set-sink-volume "${SINKc}" 50%;
echo -e "\e[91mconnect effects LADSPA directly to mic sink via looopback\e[0m";

#LADSPA_rnnoise
echo -e "\e[96mLoad module-ladspa-sink for RNNOISE\e[0m"
pactl load-module module-ladspa-sink \
                        plugin="librnnoise_ladspa" label="noise_suppressor_mono" \
                        control="0,1,25,100,25,0,0" \
                        sink_name="LADSPA_noise" \
                        master="${SINKa}";

#LADSPA_pitch
echo -e "\e[95mLoad module-ladspa-sink for pitch\e[0m"; 
pactl load-module module-ladspa-sink \
                sink_name="${SINKb}" \
                master="LADSPA_noise" \
    plugin="tap_pitch" label=tap_pitch control="1.3693,33,-11,11,1"; 

#### ladspa SINK DEBUG: hear effects, not suitable for singing because of delay
# solution: apply with ffmpeg during recording
# Connect ALSA input to first LADSPA sink ??
# maybe in handy for debug:
#pactl set-default-source alsa_input.my_input_source
#pactl set-default-sink ${SINKa}
# Route audio through chain ???
#pactl move-sink-input input_stream_id ${SINKa} ???

pactl list sources short;
echo -e "\e[94Turn capture/unmute ${SINKb}.monitor\e[0m";
pactl set-source-mute ${SINKb}.monitor 0
echo -e "\e[99ALSO set a recording volume level of 44% for ${SINKb}.monitor\e[0m";
pactl set-source-volume ${SINKb}.monitor 44%

pactl load-module module-loopback sink=${SINKb} latency_msec=111;


#### yt-dlp
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
    echo "Video rendering was cancelled."
    reboot_pulse "true"
    # Get the PID of the parent process
    parent_pid=$$
    # Call the function to kill the parent process and all its children
    kill_parent_and_children $parent_pid
    exit;
fi
      
   echo -e "\e[91mPlayback convertido para AVI\e[0m";
else
    echo "No suitable playback file found."
        reboot_pulse true;
        wmctrl -c 'BETAKê CMD prompt';
        # Get the PID of the parent process
        parent_pid=$$
        # Call the function to kill the parent process and all its children
        kill_parent_and_children $parent_pid
    exit;
    
fi

if [ ! -n "${PLAYBACK_BETA}" ]; then  
     echo "No suitable playback file converted to AVI.";
         reboot_pulse true;
         wmctrl -c 'BETAKê CMD prompt';
         # Get the PID of the parent process
        parent_pid=$$
        # Call the function to kill the parent process and all its children
        kill_parent_and_children $parent_pid
    exit;
     
fi

echo -e "\e[91mAll setup to sing!";
aplay research.wav;
# Display message to start recording
export LC_ALL=C;
zenity --question --text="\"${PLAYBACK_TITLE}\" - duration: ${PLAYBACK_LEN}, let's sing? " --title="BETAKe: ready to S I N G? " --default-cancel --width=640 --height=100
if [ $? == 1 ]; then
    echo "Recording canceled.";
        reboot_pulse true;
    wmctrl -c 'BETAKê CMD prompt';
    # Get the PID of the parent process
    parent_pid=$$
    # Call the function to kill the parent process and all its children
    kill_parent_and_children $parent_pid
    exit;
fi

rm -rf "${OUT_DIR}"/"${karaoke_name}"_*.*;
# Recording then Post-production
OUT_VIDEO="${OUT_DIR}"/"${karaoke_name}"_out.mp4;
OUT_VOCAL="${OUT_DIR}"/"${karaoke_name}"_out.flac;
	
echo -e "\e[93mSING!--------------------------\e[0m";
		echo -e "\e[99mLaunch lyrics video\e[0m";

	            ffplay \
			        -window_title "SING" -loglevel info -hide_banner -af "volume=0.35" "${PLAYBACK_BETA}" &
                ffplay_pid=$!;
                     epoch_ffplay=$( get_process_start_time "${ffplay_pid}" ); 	

pactl unload-module module-loopback;

#start CAMERA   to record audio & video
echo -e "\e[91m..Launch FFMpeg recorder (AUDIO_VIDEO)\e[0m";
 
       ffmpeg -y \
  -hide_banner -loglevel info \
        -f v4l2 -i /dev/video0 \
        -f pulse -i "${SINKb}" \
  -t "${PLAYBACK_LEN}" -map "0:v:0" "${OUT_VIDEO}" \
  -map "1:a:0" -ar 48k "${OUT_VOCAL}" \
  -f pulse "${SINKb}" &
ff_pid=$!;
  
    epoch_ff=$( get_process_start_time "${ff_pid}" ); 
    diff_ss="$(( 2 + "$(time_diff_seconds "${epoch_ffplay}" "${epoch_ff}")"))"

## echo-cancel fix
ffplay -f lavfi -i "sine=frequency=200:duration=5" -f pulse "${SINKa}" &

# Initialize variables
cronos_play=1
# Main loop
while [ "$(printf "%.0f" "${cronos_play}")" -le "$(printf "%.0f" "${PLAYBACK_LEN}")" ]; do
    wmctrl -R "BETAKe Recording" -b add,above
    sleep 1.1
    cronos_play=$(echo "scale=6; ${cronos_play} + 1.1" | bc)
    percent_play=$(echo "scale=6; ${cronos_play} * 100 / ${PLAYBACK_LEN}" | bc)
    echo "${cronos_play}" > "${OUT_DIR}/${karaoke_name}_dur.txt"
    echo "$(printf "%.0f" "${percent_play}")"
done | zenity --progress --text="Press OK to STOP recording" \
              --title="BETAKe Recording" --width=300 --height=200 --percentage=0



# Check if the progress dialog was canceled/completed
if [ $? = 1 ]; then
    echo "Recording canceled.";
    
else
    echo "Progress completed.";
fi

killall -9 aplay;
# Output the final value of karaoke_duration
cronos_play=$( cat "${OUT_DIR}/${karaoke_name}_dur.txt" );
echo "elapsed Karaoke duration: $cronos_play";
echo "Total playback duration: ${PLAYBACK_LEN}";

## when prompt window close, stop all recordings 
    # give time to buffers
    
    echo -e "\e[93mRecording finished\e[0m";
            killall -SIGINT ffmpeg;
            killall -HUP v4l2-ctl;
            killall -SIGINT sox;
            killall -9 ffplay;
    sleep 3;        
   
# clean up
pactl unload-module module-loopback;

##POSTprod
echo "POST_PROCESSING____________________________________"
echo -e "\e[90mrendering final video\e[0m"

export LC_ALL=C;  OUT_FILE="${OUT_DIR}"/"${karaoke_name}"_beta.mp4;
# Start ffmpeg in the background and capture its PID
ffmpeg -y -hide_banner -loglevel info   \
                                                            -i "${OUT_VIDEO}" \
    -ss 0"$( echo "scale=4; ${diff_ss} - 0.9669" | bc )"     -i "${PLAYBACK_BETA}" \
                                                            -i "${OUT_VOCAL}" \
        -filter_complex "
    [2:a]
    ladspa=tap_autotalent:plugin=autotalent:c=441 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.11 1.00 0 0 0 0 1.000 1.000 0 0 000.0 0.09,
   stereowiden,adynamicequalizer,aexciter,aecho=0.6:0.7:76:0.25,treble=g=8,
    loudnorm=I=-16:LRA=11:TP=-1.5,   
    aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[vocals];

    [1:a]dynaudnorm,aecho=0.8:0.6:128:0.25,   
    aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[playback];

    [playback][vocals]amix=inputs=2:weights=0.3|0.5[betamix];

        [1:v]format=rgba,colorchannelmixer=aa=0.84,scale=s=640x480[v1];
        life=s=640x480:mold=5:r=10:ratio=0.1:death_color=blue:life_color=#00ff00,boxblur=2:2,format=rgba[spats];
         gradients=n=3:type=spiral,format=rgb0,scale=s=640x480[vscope];
          [0:v]scale=s=1270x720[v0]; 
          [vscope][v1]hstack=inputs=2,scale=s=640x480[video_merge];
          [video_merge][spats]vstack=inputs=2,format=rgba,colorchannelmixer=aa=0.66,scale=s=1270x720[badcoffee];
          [v0][badcoffee]overlay=10:6,format=rgba,scale=s=1270x720[BETAKE];" \
                    -map "[betamix]"  -map "[BETAKE]" \
                    -ar 48k -t "${PLAYBACK_LEN}"   "${OUT_FILE}"  &
                ff_pid=$!;


 render_display_progress "${OUT_DIR}"/"${karaoke_name}"_beta.mp4 
# Check if the progress dialog was canceled/completed
if [ $? -eq 1 ]; then
    echo "Render canceled."
    # Kill ffmpeg process
    killall -9 ffmpeg
else    
    echo "Render FINISHED."

    # Show the result using ffplay
    ffplay -af "volume=0.45" -window_title "RESULT" -loglevel quiet \
                    -hide_banner "${OUT_FILE}" ;
fi


reboot_pulse 'the_end';
wmctrl -c 'BETAKê CMD prompt';
# Get the PID of the parent process
    parent_pid=$$
    # Call the function to kill the parent process and all its children
    kill_parent_and_children $parent_pid

    #THE END