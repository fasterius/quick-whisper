# `quick-whisper.sh`

A Bash script to record speech from your microphone, transcribe it locally with
[whisper.cpp](https://github.com/ggml-org/whisper.cpp) and copy the result
directly to your clipboard.

## Features

- Records microphone input until silence is detected
- Transcribes speech to text using `whisper.cpp`
- Copies the text result directly to your clipboard
- Fully local: nothing is sent to external servers

## Requirements

- `sox`
- `whisper.cpp`
- `pbcopy` (MacOS), `wl-copy` (Linux Wayland) or `xclip` (Linux X11)

## Usage

1. Run the script.
2. Speak into your microphone.
3. After a configurable time of silence, recording is stopped and transcribed.
4. The final text is now copied to your clipboard.

The recordings and transcriptions are stored in `/tmp` and are overwritten after
each execution of the script.

## Configuration

You can tweak a few variables at the top of the script:

```bash
WHISPER_DIR="${HOME}/opt/whisper.cpp"  # Path to whisper.cpp build
MODEL="ggml-base.en"                   # Model filename (without .bin extension)
SILENCE="1.5"                          # Seconds of silence before auto-stop
```

You might also want to add a global key bind to this script so that you can run
in from any application using _e.g._ Automator on MacOS, or your Desktop
Environment's / Window Manager's key bind utilities on Linux.
