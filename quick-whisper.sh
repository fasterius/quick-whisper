#!/usr/bin/env bash

# ---------------------------- Input variables -------------------------------

WHISPER_DIR="${HOME}/opt/whisper.cpp"
MODEL="ggml-base.en"
SILENCE="1.5"

# ----------------------------------------------------------------------------

# Bash strict mode
set -euo pipefail

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
cat /tmp/whisper_out.txt | pbcopy
