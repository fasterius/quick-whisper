#!/usr/bin/env bash

# This script records audio from the system microphone, automatically stops
# after a short period of silence, transcribes the recording using
# `whisper.cpp` and places the resulting text into the clipboard.
#
# Dependencies:
#   - sox
#   - whisper.cpp
#   - pbcopy (MacOS), wl-copy (Linux Wayland) or xclip (Linux X11)
#
# Notes:
#   - Audio and text is stored in the OUTPUT_DIR directory and is overwritten on
#     each execution of the script; the files are written as `record.wav` and
#     `whisper_out.txt`, respectively.
#   - You might want to add a global hotkey to this script so you can run it
#     from any application using e.g. Automator on MacOS.
#
# Usage:
#   quick-whisper.sh [-w WHISPER_DIR] [-o OUTPUT_DIR] [-m MODEL] [-s SILENCE_DURATION]"
#
# Example usage:
#   quick-whisper.sh
#   quick-whisper.sh -w ~/whisper.cpp
#   quick-whisper.sh -m gglm-tiny.en

# Bash strict mode
set -euo pipefail

# Help function
help() {
    echo "Usage: $0 [-w WHISPER_DIR] [-o OUTPUT_DIR] [-m MODEL] [-s SILENCE_DURATION]"
    echo
    echo "  -w   Path to whisper.cpp directory (default: ${WHISPER_DIR})"
    echo "  -o   Output directory (default: ${OUTPUT_DIR})"
    echo "  -m   Model name without .bin extension (default: ${MODEL})"
    echo "  -s   Silence duration in seconds (default: ${SILENCE_DURATION})"
    echo "  -h   Show this help"
    exit 1
}

# Default configuration
WHISPER_DIR="${HOME}/opt/whisper.cpp"
OUTPUT_DIR="/tmp"
MODEL="ggml-base.en"
SILENCE_DURATION="1.5"

# Parse options
while getopts ":d:m:s:o:h" opt; do
    case ${opt} in
        w ) WHISPER_DIR="$OPTARG" ;;
        o ) OUTPUT_DIR="$OPTARG" ;;
        m ) MODEL="$OPTARG" ;;
        s ) SILENCE_DURATION="$OPTARG" ;;
        h ) help ;;
        \? ) echo "Invalid option: -$OPTARG" >&2; help ;;
        : ) echo "Option -$OPTARG requires an argument." >&2; help ;;
    esac
done

# Check for clipboard utility availability
if command -v pbcopy &> /dev/null; then
    CLIPBOARD_CMD="pbcopy" # MacOS
elif command -v wl-copy &> /dev/null; then
    CLIPBOARD_CMD="wl-copy" # Linux Wayland
elif command -v xclip &> /dev/null; then
    CLIPBOARD_CMD="xclip -selection clipboard" # Linux X11
else
    echo "Error: no clipboard utility found" >&2
    exit 1
fi

# Record until there is silence for the specified number of seconds
# Resample down to 16kHz, as that's what `whisper.cpp` is trained on
rec \
    --no-show-progress \
    --channels 1 \
    --bits 16 \
    "${OUTPUT_DIR}/record.wav" \
    rate 16000 \
    silence 1 0 0% 1 "${SILENCE_DURATION}" 1%

# Transcribe using `whisper.cpp`
${WHISPER_DIR}/build/bin/whisper-cli \
    --model "${WHISPER_DIR}/models/${MODEL}.bin" \
    --file "${OUTPUT_DIR}/record.wav" \
    --output-file "${OUTPUT_DIR}/whisper_out" \
    --output-txt

# Copy to clipboard
cat "${OUTPUT_DIR}/whisper_out.txt" | "$CLIPBOARD_CMD"

# Play sound to notify the user that recording is finished
play -n synth .1 sin 667 gain -15 &> /dev/null
