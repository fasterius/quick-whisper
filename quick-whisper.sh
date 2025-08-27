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
# Configuration:
#   - WHISPER_DIR: Path to the whisper.cpp installation directory
#   - MODEL      : Model name (without the .bin extension) in whisper.cpp/models
#   - SILENCE    : Duration of silence (in seconds) after which recording stops
#
# Notes:
#   - Audio is temporarily stored in /tmp/record.wav and removed on overwrite.
#   - Transcribed text is written to /tmp/whisper_out.txt before copying.
#   - You might want to add a global hotkey to this script so you can run it
#     from any application using e.g. Automator on MacOS.
#
# Example:
#   ./quick-whisper.sh
#   # Speak: "Hello world"
#   # Clipboard contains: "Hello world"

# ----------------------------- Configuration --------------------------------

WHISPER_DIR="${HOME}/opt/whisper.cpp"
MODEL="ggml-base.en"
SILENCE="1.5"

# -------------------- Do not change beyond this point -----------------------

# Bash strict mode
set -euo pipefail

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
    /tmp/record.wav \
    rate 16000 \
    silence 1 0 0% 1 "${SILENCE}" 1%

# Transcribe using `whisper.cpp`
${WHISPER_DIR}/build/bin/whisper-cli \
    --model "${WHISPER_DIR}/models/${MODEL}.bin" \
    --file /tmp/record.wav \
    --output-file /tmp/whisper_out \
    --output-txt

# Copy to clipboard
cat /tmp/whisper_out.txt | "$CLIPBOARD_CMD"

# Play sound to notify the user that recording is finished
play -n synth .1 sin 667 gain -15 &> /dev/null
