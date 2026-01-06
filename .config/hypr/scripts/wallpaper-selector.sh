#!/bin/bash

WALLPAPER_DIR="$HOME/dotfiles/wallpapers/animated"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"

# Create cache directory
mkdir -p "$CACHE_DIR"

# Find all video files
wallpapers=$(find "$WALLPAPER_DIR" -type f \( -name '*.mp4' -o -name '*.mkv' -o -name '*.webm' -o -name '*.avi' -o -name '*.gif' \) | sort)

# Build options with thumbnails
options=""
declare -A path_map
while IFS= read -r path; do
    filename=$(basename "$path")
    name="${filename%.*}"
    display_name="${name//[-_]/ }"
    display_name="${display_name^}"
    thumb="$CACHE_DIR/$name.png"

    # Generate thumbnail if it doesn't exist
    if [[ ! -f "$thumb" ]]; then
        ffmpeg -y -i "$path" -ss 00:00:01 -vframes 1 -vf "scale=64:64:force_original_aspect_ratio=decrease" "$thumb" 2>/dev/null
    fi

    # Use wofi image format
    if [[ -f "$thumb" ]]; then
        options+="img:$thumb:text:$display_name\n"
    else
        options+="$display_name\n"
    fi
    path_map["$display_name"]="$path"
done <<< "$wallpapers"

# Show wofi menu
selected=$(echo -en "$options" | head -c -1 | wofi --dmenu --prompt "Wallpaper" --cache-file /dev/null --allow-images)

# Exit if nothing selected
[[ -z "$selected" ]] && exit 0

# Extract display name (wofi returns full line with img prefix)
if [[ "$selected" == img:* ]]; then
    selected="${selected##*:text:}"
fi

# Get full path
wallpaper_path="${path_map[$selected]}"

pkill -o mpvpaper 
sleep 0.2
mpvpaper -o "loop no-audio --panscan=1.0" ALL "$wallpaper_path" --fork
