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

mkdir -p "$REC_DIR";
mkdir -p "$OUT_DIR";

reboot_pulse() {
    colorecho "yellow" "Unload existing modules and restart PulseAudio"
    pactl unload-module module-ladspa-sink
    pactl unload-module module-loopback
    pactl unload-module module-echo-cancel
    colorecho "red" "ERRORS reported above HERE ARE NORMAL. It means already unloaded"
    colorecho "yellow" "[[[[RESTARTING]]]]  audio server now:"
    killall -HUP pipewire-pulse
    sleep 1
}

colorecho() {
    color=$1
    message=$2
    case $color in
        "black") coding="\e[30m" ;;
        "red") coding="\e[31m" ;;
        "green") coding="\e[32m" ;;
        "yellow") coding="\e[33m" ;;
        "blue") coding="\e[34m" ;;
        "magenta") coding="\e[35m" ;;
        "cyan") coding="\e[36m" ;;
        "white") coding="\e[37m" ;;
        *) coding="\e[33m"  ;;
    esac
    echo -e "${coding}${message}\e[0m"
}

reboot_pulse 'done'

kill_parent_and_children() {
    local parent_pid=$1
    local child_pids=$(pgrep -P $parent_pid)

    colorecho "red" "Killing parent process $parent_pid and its children: $child_pids"
    kill $parent_pid $child_pids

    sleep 1

    for pid in $parent_pid $child_pids; do
        if ps -p $pid > /dev/null; then
            colorecho "red" "Process $pid is still running"
        else
            colorecho "red" "Process $pid has been terminated"
        fi
    done
}

render_display_progress() {
    local video_bitrate=512
    local audio_bitrate=128
    local duration_seconds="${PLAYBACK_LEN}"
    local pid_ffmpeg="$1"

    local video_bitrate_bps=$((video_bitrate * 1000))
    local audio_bitrate_bps=$((audio_bitrate * 1000))
    local video_size=$((video_bitrate_bps * duration_seconds))
    local audio_size=$((audio_bitrate_bps * duration_seconds))
    local total_size_bytes=$(( (video_size + audio_size) / 8 ))
    local total_size_mb=$(echo "scale=1; $total_size_bytes / (1024 * 1024)" | bc)

    (
    while true; do
        if ! ps -p "$ff_pid" >/dev/null 2>&1; then
            break
        fi
        wmctrl -r "Rendering" -b add,above
        local current_file_size=$(stat -c%s "${1}" )
        local progress=$(echo "scale=1; ($current_file_size * 100) / $total_size_bytes" | bc)
        if [ "$(echo "scale=0; "progress/1 | bc)" -ge 95 ]; then
            progress=95;
        fi
        echo "$progress"
        sleep 0.5
    done
    ) | zenity --progress --title="Rendering" --text="Rendering in progress...please wait" --auto-close --auto-kill
}

generate_mp3() {
    local mp4_file="$1"
    local mp3_file="$2"
    ffmpeg -y -hide_banner -loglevel error -i "$mp4_file" -vn -acodec libmp3lame -q:a 4 "$mp3_file"
}

get_process_start_time() {
    local pid="$1"
    local start_epoch_seconds=$(ps -o lstart= -D "%s" -p "$pid")
    echo "$start_epoch_seconds"
}

get_file_modification_time() {
    local file="$1"
    local mod_time=$(stat -c %Y "$file")
    echo "$mod_times"
}

time_diff_seconds() {
    local start_secs="$1"
    local end_secs="$2"
    echo -e "$(( (end_seconds - start_seconds) ))"
}

get_mic_format() {

    input_config="$(pactl list short sinks |  grep -m 1 "${MIC_src}" );"
    echo "$input_config" | awk '{print $4}';
}

generate_sox_config() {
    out_file=$1
    
    source_name=$2

    source_config=$(pactl list short sources |  grep -m 1 "${SRC_mic}" );

    encoding=$(echo "$source_config" | awk '{print $4}')
    channels=$(echo "$source_config" | awk '{print $5}'| tr -cd '[:digit:]')
    sample_rate=$(echo "$source_config" | awk '{print $6}'| tr -cd '[:digit:]')

    if [[ $encoding == *float* ]]; then
        sox_encoding="floating-point";
    else
        sox_encoding="signed-integer";
    fi
    
    bit_rate=$(echo "$source_config" | awk '{print $4}' | tr -cd '[:digit:]');

    sox_command="parec --device=${source_name} --latency=33 |
                 sox -t raw -r 44100 -e $sox_encoding -b 16 -c 2 - -t wav -r 44100 -b 16 -c 2 -e signed-integer ${out_file}.wav  dither "

    echo "$sox_command"
}

select_source() {
    keyword="$1"

    source_name=$( pactl list short sinks | grep -m1 "$keyword" | awk '{print $2}')

    echo "$source_name"
}

SummonSoX() {
    if [ $# -ne 2 ]; then
        colorecho "red" "Usage: $0 <output_file> <source_keyword>"
        exit 1
    fi

    out_file="$1"
    source_keyword="$2"

    selected_source=$(select_source "$source_keyword")
    sox_config=$(generate_sox_config "$out_file" "$selected_source")

    colorecho "green" "Sox configuration for recording from $selected_source:"
    echo "$sox_config" > "$OUT_DIR"/"$karaoke_name"_sox.sh;
    
}


# Function to query V4L2 device parameters
query_v4l2_params() {
    device=$1

    # Query device resolution
    resolution=$(v4l2-ctl --list-formats-ext -d "$device" | grep "Size:" | head -n 1 | awk '{print $3}');

    # Query device frame rate
    framerate=$(v4l2-ctl --list-formats-ext -d "$device" | grep "Interval"| head -n 1 | cut -d\( -f2  | cut -d\. -f1);

    # Query device video format
    #format=$(v4l2-ctl --list-formats-ext -d "$device" | grep "Format:" | head -n 1 | awk '{print $3}')

    echo "$resolution $framerate" #$format"
}

# Function to generate V4L2 configuration
generate_v4l2_config() {
    device=$1
    output=$2

    # Query V4L2 parameters
    params=$(query_v4l2_params "$device")
    resolution=$(echo "$params" | awk '{print $1}')
    framerate=$(echo "$params" | awk '{print $2}')
    format=$(echo "$params" | awk '{print $3}')

    # Generate V4L2 command
    v4l2_command="ffmpeg -y -hide_banner -loglevel info -f v4l2 -video_size ${resolution} -framerate ${framerate} -i ${device} -c:v copy ${output}.avi"

    echo "$v4l2_command"
}

# Function to determine the default V4L2 device name
get_default_v4l2_device() {
    default_device=$(v4l2-ctl --list-devices | awk '{ print $1 }' | xargs | cut -d: -f2 | awk '{ print $1 }')
    echo "$default_device"
}

FiatFF() {
if [ $# -ne 1 ]; then
    echo "Usage: $0 <output>"
    exit 1
fi

# Output file
output="$1"

# Determine default V4L2 device
default_device=$(get_default_v4l2_device)

# Generate V4L2 configuration
v4l2_config=$(generate_v4l2_config "$default_device" "$output")

echo "V4L2 configuration for capturing video from default device $default_device:"
echo "$v4l2_config" > "${OUT_DIR}"/"${karaoke_name}"_ff.sh;

}

#LOG_FILE="$betake_path/script.log"
SINKa="beta_mic";
SINKb="beta_ladspa";
SINKc="$( pactl get-default-sink )";
SRC_mic="$( pactl get-default-source )";
FMT_mic=$( get_mic_format true )

colorecho "yellow" "${SINKa} ${SINKb} ${SINKc} ${SRC_mic} ${FMT_mic}";
colorecho "green" "*HOUSEKEEPING SOUND SERVERS*";
colorecho "red" "INIT MIC\"SINK A\"";
colorecho "blue" "GOT mic encoding: ${FMT_mic}";
colorecho "green" "Loading module-remap-source for microphone sink";
pactl load-module module-remap-source source_name="${SINKa}" source_master="${SRC_mic}" format="${FMT_mic}";

colorecho "green" "connect effects LADSPA directly to mic sink via looopback";

#colorecho "green" "Load module-ladspa-sink for RNNOISE";
#pactl load-module module-ladspa-sink \
#    plugin="librnnoise_ladspa" label="noise_suppressor_mono" \
#    control="-1,0,50,500,50" \
#    sink_name="LADSPA_noise" \
#    format="${FMT_mic}" \
#    master="${SINKa}"

colorecho "green" "Load module-ladspa-sink for pitch"
pactl load-module module-ladspa-sink \
    sink_name="${SINKb}" \
    master="${SINKa}" \
    plugin="tap_pitch" label=tap_pitch control="5.0609606,77,1,1" \
    format="${FMT_mic}";

for target in "${SINKa}" "${SINKb}" "LADSPA_pitch" "LADSPA_noise"; do
    colorecho "yellow" "Set sink format ${FMT_mic} -> $target";
    pactl set-sink-format "$target" "${FMT_mic}";
done

colorecho "green" "Ajustar vol ${SRC_mic} em 33%";
pactl set-source-volume "${SRC_mic}" 33%;
colorecho "green" "Ajustar vol ${SINKa} USE HEADPHONES";
pactl set-source-volume "${SINKa}" 90%;
colorecho "blue" "Ajustar vol ${SINKb} 90%";
pactl set-sink-volume "${SINKb}" 90%;
colorecho "green" "Ajustar vol ${SINKb}.monitor 90%";
pactl set-source-volume "${SINKb}".monitor 90%;
colorecho "green" "Ajustar vol ${SINKc} 50%..";
pactl set-sink-volume "${SINKc}" 50%;
pactl list sources short;
colorecho "blue" "Turn capture/unmute ${SINKb}.monitor";
pactl set-source-mute ${SINKb}.monitor 0;
colorecho "magenta" "ALSO set a recording volume level of 44% for ${SINKb}.monitor";
pactl set-source-volume ${SINKb}.monitor 44%;

# Create a loopback source
pactl load-module module-null-sink sink_name=loopback_sink
pactl load-module module-loopback source=${SINKb}.monitor sink=loopback_sink

pactl load-module module-loopback source=loopback_sink.monitor sink="${SINKc}";



PLAYBACK_BETA="${REC_DIR}/${karaoke_name}_playback.mp4";

rm -rf "${REC_DIR}"/"${karaoke_name}"_playback.*;

PLAYBACK_TITLE="$(yt-dlp --get-title "${video_url}")"
yt-dlp "${video_url}" -o "${REC_DIR}/${karaoke_name}_playback.%(ext)s" \
--format 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' \
--console-title --embed-subs --progress --no-continue --force-overwrites \
--default-search "ytsearch: karaoke Lyrics --match-filter duration < 300"

filename=$(find "$REC_DIR" \( -name "${karaoke_name}_playback.mkv" -o -name "${karaoke_name}_playback.mp4" -o -name "${karaoke_name}_playback.webm" \) -print -quit)

if [ -n "$filename" ]; then
    echo "Using file: $filename"

    PLAYBACK_LEN=$(echo "scale=0; $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${filename}")/1" | bc)

    ffmpeg -y -hide_banner -loglevel info -i "${filename}" "${PLAYBACK_BETA}" &
    ff_pid=$!

    render_display_progress "${PLAYBACK_BETA}"

    if [ $? -eq 0 ]; then
        echo "Video rendering completed successfully."
    else
        echo "Video rendering was cancelled."
        reboot_pulse "true"
        parent_pid=$$
        kill_parent_and_children $parent_pid
        exit
    fi

    echo -e "\e[91mPlayback convertido para AVI\e[0m"
else
    echo "No suitable playback file found."
    reboot_pulse true
    wmctrl -R "gammaQ CMD prompt"
    wmctrl -c "gammaQ CMD prompt"
    parent_pid=$$
    kill_parent_and_children $parent_pid
    exit
fi

if [ ! -n "${PLAYBACK_BETA}" ]; then  
    echo "No suitable playback file converted to AVI."
    reboot_pulse true
    wmctrl -R "gammaQ CMD prompt"
    wmctrl -c "gammaQ CMD prompt"
    parent_pid=$$
    kill_parent_and_children $parent_pid
    exit
fi

echo -e "\e[91mAll setup to sing!\e[0m"
aplay research.wav

export LC_ALL=C
zenity --question --text="\"${PLAYBACK_TITLE}\" - duration: ${PLAYBACK_LEN}, let's sing?" \
--title="Ready to S I N G?" --default-cancel --width=640 --height=100

if [ $? == 1 ]; then
    echo "Recording canceled."
    reboot_pulse true
    wmctrl -R "gammaQ CMD prompt"
    wmctrl -c "gammaQ CMD prompt"
    parent_pid=$$
    kill_parent_and_children $parent_pid
    exit
fi

rm -rf "${OUT_DIR}"/"${karaoke_name}"_*.*

OUT_VIDEO="${OUT_DIR}"/"${karaoke_name}"_out
OUT_VOCAL="${OUT_DIR}"/"${karaoke_name}"_out.wav


ffplay -window_title "SING" -loglevel info -hide_banner -af "volume=0.25" "${PLAYBACK_BETA}" &
ffplay_pid=$!
epoch_ffplay=$(get_process_start_time "${ffplay_pid}")


FiatFF "${OUT_VIDEO}"
/bin/sh "$OUT_DIR"/"$karaoke_name"_ff.sh &
ff_pid=$!

epoch_ff=$( get_process_start_time "${ff_pid}" ); 
diff_ss="$(( 1 + "$(time_diff_seconds "${epoch_ffplay}" "${epoch_ff}")"))"

SummonSoX "${OUT_VIDEO}".wav loopback_sink.monitor; 
/bin/sh "$OUT_DIR"/"$karaoke_name"_sox.sh &
#sox_pid=$!;


cronos_play=1

while [ "$(printf "%.0f" "${cronos_play}")" -le "$(printf "%.0f" "${PLAYBACK_LEN}")" ]; do
    wmctrl -r "Recording" -b add,above
    sleep 1.1
    cronos_play=$(echo "scale=6; ${cronos_play} + 1.1" | bc)
    percent_play=$(echo "scale=6; ${cronos_play} * 100 / ${PLAYBACK_LEN}" | bc)
    echo "${cronos_play}" > "${OUT_DIR}/${karaoke_name}_dur.txt"
    # shellcheck disable=SC2005
    echo "$(printf "%.0f" "${percent_play}")"
done | zenity --progress --text="Press OK to STOP recording" \
              --title="Recording" --width=300 --height=200 --percentage=0

if [ $? = 1 ]; then
    echo "Recording canceled."
else
    echo "Progress completed."
fi

pactl unload-module module-loopback
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
   
cronos_play=$(cat "${OUT_DIR}/${karaoke_name}_dur.txt")
colorecho "green" "elapsed Karaoke duration: $cronos_play"
colorecho "blue" "Total playback duration: ${PLAYBACK_LEN}"

echo "POST_PROCESSING____________________________________"
colorecho "red" "Rendering postprocessed video"

export LC_ALL=C
FINAL_FILE="${OUT_DIR}"/"${karaoke_name}"_beta.mp4

ffmpeg -y -hide_banner -loglevel  info \
    -i "${OUT_VIDEO}.avi" \
    -ss "$(echo "scale=4; ${diff_ss} - 1.4444" | bc | sed 's/-\./-0\./g')" -i "${PLAYBACK_BETA}" \
    -i "${OUT_VIDEO}.wav" \
    -filter_complex "
        [2:a]
        ladspa=tap_autotalent:plugin=autotalent:c=441 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1.00 1.00 0 0 0 0 1.000 1.000 0 0 000.0 1.00,
        stereowiden,adynamicequalizer,aexciter,aecho=0.6:0.7:111:0.3,treble=g=3,
        loudnorm=I=-16:LRA=11:TP=-1.5,
        aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
        aresample=resampler=soxr:osf=s16[vocals];

        [1:a]
        dynaudnorm,aecho=0.8:0.6:128:0.25,
        aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo,
        aresample=resampler=soxr:osf=s16[playback];

        [playback][vocals]amix=inputs=2:weights=0.7|0.6[betamix];

        [1:v]format=rgba,colorchannelmixer=aa=0.84,scale=s=424x240[v1];
        life=s=424x240:mold=5:r=10:ratio=0.1:death_color=blue:life_color=#00ff00,boxblur=2:2,format=rgba[spats];
        gradients=n=3:type=spiral,format=rgb0,scale=s=424x240[vscope];
        [0:v]scale=s=848x408[v0];
        [vscope][v1]hstack=inputs=2,scale=s=424x240[video_merge];
        [video_merge][spats]vstack=inputs=2,format=rgba,colorchannelmixer=aa=0.66,scale=s=848x408[badcoffee];
        [v0][badcoffee]overlay=10:3,format=rgba,scale=s=848x408[BETAKE];" \
    -map "[betamix]" -map "[BETAKE]" \
    -ar 48k -t "${PLAYBACK_LEN}" "${FINAL_FILE}" &
ff_pid=$!

render_display_progress "${FINAL_FILE}"

ffplay -window_title "Obrigado pela participação!" "${FINAL_FILE}"

zenity --info --text="Thank you, hope you enjoyed." --title="Finished"  --width=640 --height=100


wmctrl -c "gammaQ CMD prompt"
reboot_pulse 'the_end'
exit





