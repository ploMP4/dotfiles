#!/bin/bash
# Print the wallpaper list as TSV: <thumbnail>\t<video>\t<display name>.
# Generates a thumbnail (for the quickshell grid) on first sight of a wallpaper.
set -euo pipefail

WALLPAPER_DIR="$HOME/dotfiles/wallpapers/animated"
THUMBS="$HOME/.cache/wallpaper-thumbs-lg"
mkdir -p "$THUMBS"

find "$WALLPAPER_DIR" -type f \( -name '*.mp4' -o -name '*.mkv' -o -name '*.webm' -o -name '*.avi' -o -name '*.gif' \) \
  | sort | while IFS= read -r path; do
    name="$(basename "$path")"; name="${name%.*}"
    thumb="$THUMBS/$name.png"
    if [[ ! -f "$thumb" ]]; then
        ffmpeg -y -ss 00:00:02 -i "$path" -frames:v 1 -vf "scale=420:-1" "$thumb" 2>/dev/null \
          || ffmpeg -y -i "$path" -frames:v 1 -vf "scale=420:-1" "$thumb" 2>/dev/null \
          || continue
    fi
    name="${name//[-_]/ }"
    printf '%s\t%s\t%s\n' "$thumb" "$path" "${name^}"
done
