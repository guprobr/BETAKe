#!/bin/bash

# Function to convert frequency to musical note
freq_to_note() {
    freq=$1
    notes=(C C# D D# E F F# G G# A A# B)
    a=440  # Frequency of A4
    b=$(echo "scale=10; l(2)" | bc -l)
    n=$(echo "scale=10; 12 * l($freq / $a) / $b" | bc -l)
    rounded_n=$(echo "$n + 0.5" | bc -l | awk '{printf("%d\n",$1 + 0.5)}')
    index=$(echo "(($rounded_n % 12) + 12) % 12" | bc)
    echo "${notes[$index]}"
}

# Path to the audio file
AUDIO_FILE="$1"

# Check if the audio file exists
if [ ! -f "$AUDIO_FILE" ]; then
    exit 1
fi
# Get the duration of the audio file
DURATION=$(soxi -D "$AUDIO_FILE")

# Calculate the start time and duration for analyzing 25% of the song
SEGMENT_START=5
SEGMENT_DURATION=$(awk "BEGIN {print int($DURATION * 0.25 + 0.5)}")

# Parameters for aubio's pitch detection
WIN_S=8096
HOP_S=$((WIN_S / 2))

# Extract a segment of the audio file
AUDIO_SEGMENT=$(mktemp).wav
sox "$AUDIO_FILE" "$AUDIO_SEGMENT" trim "$SEGMENT_START" "$SEGMENT_DURATION"

# Run aubio pitch detection on the segment
aubio_pitch_output=$(aubio pitch "$AUDIO_SEGMENT" -H $HOP_S -B $WIN_S 2>&1)
aubio_exit_code=$?

# Clean up temporary audio segment
rm "$AUDIO_SEGMENT"

if [ $aubio_exit_code -ne 0 ]; then
    echo "aubio error: $aubio_pitch_output"
    exit 1
fi

# Extract pitches from aubio output
mapfile -t pitches < <(echo "$aubio_pitch_output" | awk '{print $2}');

# Convert pitches to notes
declare -A note_count
for pitch in "${pitches[@]}"; do
    if (( $(echo "$pitch > 0" | bc -l) )); then
        note=$(freq_to_note "$pitch")
        ((note_count[$note]++))
    fi
done

# Determine the most frequent note
most_frequent_note=""
max_count=0
for note in "${!note_count[@]}"; do
    if (( note_count[$note] > max_count )); then
        most_frequent_note=$note
        max_count=${note_count[$note]}
    fi
done

# Determine if the most frequent note fits the major scale pattern
major_scale_notes=("C" "D" "E" "F" "G" "A" "B")
if [[ " ${major_scale_notes[*]} " == *"$most_frequent_note"* ]]; then
    detected_key="$most_frequent_note\\ major"
else
    detected_key="$most_frequent_note\\ minor"
fi

# Output the detected key
echo "$detected_key"

