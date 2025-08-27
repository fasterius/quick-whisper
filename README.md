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

## Installation

Clone this repository and copy/symlink the `quick-whisper.sh` script in your
`PATH`:

```bash
git clone git@github.com:fasterius/quick-whisper.git
cp quick-whisper.sh ~/.local/bin
```

You might also want to add a global key bind to this script so that you can run
in from any application using _e.g._ Automator on MacOS, or your Desktop
Environment's / Window Manager's key bind utilities on Linux (in which case you
can use the full path without copying/symlinking to your `PATH`).

## Usage

```bash
quick-whisper.sh [-w WHISPER_DIR] [-o OUTPUT_FILE] [-m MODEL] [-s SILENCE_DURATION]"
```

1. Run the script.
2. Speak into your microphone.
3. After a configurable time of silence, recording is stopped and transcribed.
4. The final text is now copied to your clipboard and a sound is played.
