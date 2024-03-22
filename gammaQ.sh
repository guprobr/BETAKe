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
    sleep 1; echo "please wait a brief moment";
}

reboot_pulse 'done';

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
            local progress=$(echo "scale=2; ($current_file_size * 100) / $total_size_bytes" | bc)

            # Update the progress bar in the dialog
            echo "$progress"

            sleep 1
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


#LADSPA_declip
echo -e "\e[97mLoad module-ladspa-sink for declipper\e[0m";
pactl load-module module-ladspa-sink \
                plugin="declip_1195" label=declip \
                sink_name="LADSPA_declip" \
                master="${SINKa}";

LADSPA_rnnoise
echo -e "\e[96mLoad module-ladspa-sink for RNNOISE\e[0m"
pactl load-module module-ladspa-sink \
                        plugin="librnnoise_ladspa" label="noise_suppressor_mono" \
                        sink_name="LADSPA_noise" \
                        master="LADSPA_declip";

#LADSPA_pitch
echo -e "\e[95mLoad module-ladspa-sink for pitch\e[0m"; 
pactl load-module module-ladspa-sink \
                sink_name="${SINKb}" \
                master="LADSPA_noise" \
    plugin="tap_pitch" label=tap_pitch control="1.005696,11,-11,5,-1"; 

#LADSPA AUTOTALENT TAP
#echo -e "\e[94mAltoTalent©\e[0m";
#pactl load-module module-ladspa-sink plugin="tap_autotalent" label=autotalent \
#                sink_name="LADSPA_talent" \
#                master="LADSPA_pitch" \
#        control="480,0,0.0000,0,0,0,0,0,0,0,0,0,0,0,0,0.11,1.00,0,0,0,0,1.000,1.000,0,0,000.0,0.09696";

#LADSPA sc4
#echo -e "\e[93mSC4\e[0m";
#pactl load-module module-ladspa-sink plugin="sc4_1882" label=sc4 \
 #               sink_name="${SINKb}"   \
 #               master="LADSPA_talent";


echo -e "\e[91maAjustar vol ${SRC_mic} em 45%";
 pactl set-source-volume "${SRC_mic}" 45%;
echo -e "\e[91maAjustar vol ${SINKa} USE HEADPHONES\e[0m";
 pactl set-source-volume "${SINKa}" 95%;
echo -e "\e[94maAjustar vol ${SINKb} 90%\e[0m";
 pactl set-sink-volume "${SINKb}" 95%;
echo -e "\e[91maAjustar vol ${SINKb}.monitor 90%\e[0m";
 pactl set-source-volume "${SINKb}".monitor 90%;
echo -e "\e[92maAjustar vol ${SINKc} 55%..\e[0m";
 pactl set-sink-volume "${SINKc}" 55%;
echo -e "\e[91mconnect effects LADSPA directly to mic sink via looopback\e[0m";


## iniciar preparo de adquirir playback e construir pipeline do gravador
PLAYBACK_BETA="${REC_DIR}/${karaoke_name}_playback.avi";
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

#"Load the echo cancellation module to cancel echo";
#echo -e "\e[98mLoad module-echo-cancel\e[0m";
#pactl load-module module-echo-cancel \
      #          sink_name="PULSE_echocan" \
     #           master="${SINKa}" \
    #aec_method=webrtc aec_args="analog_gain_control=1 digital_gain_control=1";
#### DEBUG: hear effects, not suitable for singing because of delay
#pactl load-module module-loopback source="${SINKa}" sink="${SINKb}" latency_msec=11;
pactl load-module module-loopback latency_msec=6;

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
    wmctrl -c 'BETAKê CMD prompt';
    exit;
fi
      
   echo -e "\e[91mPlayback convertido para AVI\e[0m";
else
    echo "No suitable playback file found."
        reboot_pulse true;
        wmctrl -c 'BETAKê CMD prompt';
    exit;
    
fi

if [ ! -n "${PLAYBACK_BETA}" ]; then  
     echo "No suitable playback file converted to AVI.";
         reboot_pulse true;
         wmctrl -c 'BETAKê CMD prompt';
    exit;
     
fi

echo -e "\e[91mAll setup to sing!";
aplay research.wav;
# Display message to start recording
export LC_ALL=C;
zenity --question --text="Ready to record: \"${PLAYBACK_TITLE}\" - duration: ${PLAYBACK_LEN}, do you want to sing this playback? " --title="BETAKe Recording Prompt" --default-cancel --width=200 --height=100
if [ $? == 1 ]; then
    echo "Recording canceled.";
        reboot_pulse true;
    wmctrl -c 'BETAKê CMD prompt';
    exit;
fi

# Recording then Post-production
OUTFILE="${OUT_DIR}"/"${karaoke_name}"_out.avi;
	
echo -e "\e[93mSING!--------------------------\e[0m";
		echo -e "\e[99mLaunch lyrics video\e[0m";

	            ffplay \
			        -window_title "SING" -loglevel info -hide_banner -af "volume=0.35" "${PLAYBACK_BETA}" &
                ffplay_pid=$!;
                     epoch_ffplay=$( get_process_start_time "${ffplay_pid}" ); 	

#start CAMERA   to record audio & video
echo -e "\e[91m..Launch FFMpeg recorder (AUDIO_VIDEO)\e[0m";
diff_ss=$(( "$(time_diff_seconds "${epoch_ffplay}" "$(date +'%s')")" ));

ffmpeg -y                                                  \
                                -hide_banner -loglevel info              \
                                        -f v4l2     -i /dev/video0        \
                                        -f pulse    -i "${SINKb}".monitor  \
                    -ss $(( 3 + "${diff_ss}" ))     -i "${PLAYBACK_BETA}"   \
                                                                                                       \
                                        -map "0:v:0" -t "${PLAYBACK_LEN}" "${OUTFILE}"               \
                                        -map "1:a:0" -ar 48k "${OUT_DIR}"/"${karaoke_name}"_out.flac &
                                        
                                
#!/bin/bash

# Initialize variables
cronos_play=0
# Main loop
while [ "$(printf "%.0f" "${cronos_play}")" -le "${PLAYBACK_LEN}" ]; do
    wmctrl -R "BETAKe Recording" -b add,above
    sleep 3.3
    cronos_play=$(echo "scale=0; ${cronos_play} + 3.3" | bc)
    percent_play=$(echo "scale=0; ${cronos_play} * 100 / ${PLAYBACK_LEN}" | bc)
    echo "${cronos_play}" > "${OUT_DIR}/${karaoke_name}_dur.txt"
    echo "${percent_play}"
done | zenity --progress --text="Press OK to STOP recording" \
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

# Start ffmpeg in the background and capture its PID
ffmpeg -y -hide_banner -loglevel info   \
                                            -i "${OUTFILE}" \
                                            -i "${PLAYBACK_BETA}" \
                                            -i "${OUT_DIR}"/"${karaoke_name}"_out.flac \
        -filter_complex "
    [1:a]loudnorm=I=-16:LRA=11:TP=-1.5,   
    aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[playback];
    [2:a]anlmdn=s=15,alimiter,speechnorm,
    pan=stereo|c0=c0|c1=c0,acompressor,
    ladspa=tap_autotalent:plugin=autotalent:c=480 0 0.0000 0 0 0 0 0 0 0 0 0 0 0 0 1.00 1.00 0 0 0 0 1.000 1.000 0 0 000.0 0.11,
    aecho=0.8:0.6:84:0.25,treble=g=5,
    loudnorm=I=-16:LRA=11:TP=-1.5,   
    aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
    aresample=resampler=soxr:osf=s16[vocals];

    [playback][vocals]amix=inputs=2:weights=0.4|0.5[betamix];

        [1:v]format=rgba,colorchannelmixer=aa=0.44,scale=s=320x240[v1];
        life=s=320x240:mold=10:r=100:ratio=0.1:death_color=blue:life_color=#00ff00,boxblur=2:2,format=rgba[spats];
         gradients=n=3:type=spiral,format=rgb0,scale=s=320x240[vscope];
          [0:v]colorchannelmixer=aa=0.55,scale=s=848x480[v0]; 
          [vscope][v1]hstack=inputs=2,scale=s=320x240[video_merge];
          [video_merge][spats]vstack=inputs=2,format=rgba,colorchannelmixer=aa=0.36,scale=s=848x480[badcoffee];
          [v0][badcoffee]overlay=10:6,format=rgba,scale=s=848x480[BETAKE];" \
                    -map "[betamix]"  -map "[BETAKE]" \
                    -b:v 333k -b:a 1024k -t "${PLAYBACK_LEN}"   "${OUT_DIR}"/"${karaoke_name}".mp4  &
                ff_pid=$!;


 render_display_progress "${REC_DIR}"/"${karaoke_name}".mp4 
# Check if the progress dialog was canceled/completed
if [ $? = 1 ]; then
    echo "Render canceled."
    # Kill ffmpeg process
    killall -9 ffmpeg
else
    # Show the result using ffplay
    ffplay -af "volume=0.45" -window_title "RESULT" -loglevel quiet \
                    -hide_banner "${OUT_DIR}/${karaoke_name}.mp4";
fi


reboot_pulse 'the_end';
wmctrl -c 'BETAKê CMD prompt';