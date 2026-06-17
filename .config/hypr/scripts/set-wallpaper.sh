#!/bin/bash
# Switch the wallpaper (with a crossfade) and re-theme the desktop to match.
# Reusable core shared by the quickshell picker.
#
# Usage:
#   set-wallpaper.sh <wallpaper|--shuffle> [shader|--shuffle|none]
#     wallpaper : a video path, or --shuffle for a random one
#     shader    : a .glsl path, --shuffle for a random one, or none/omitted
set -euo pipefail
export PATH="$HOME/.cargo/bin:$PATH"

WALLPAPER_DIR="$HOME/dotfiles/wallpapers/animated"
SHADER_DIR="$HOME/.config/phonto/shaders"
PHONTO="/home/plo/sandbox/phonto/target/release/phonto"
APPLY="$HOME/.config/hypr/scripts/wallust-apply.sh"

target="${1:-}"
shader="${2:-}"

random_wallpaper() {
    find "$WALLPAPER_DIR" -type f \( -name '*.mp4' -o -name '*.mkv' -o -name '*.webm' -o -name '*.avi' -o -name '*.gif' \) | shuf -n1
}
[[ "$target" == "--shuffle" ]] && target="$(random_wallpaper)"
case "$shader" in
    --shuffle|--random) shader="$(find "$SHADER_DIR" -name '*.glsl' | shuf -n1)" ;;
    none|"") shader="" ;;
esac

[[ -z "$target" || ! -f "$target" ]] && { echo "set-wallpaper: no such wallpaper: $target" >&2; exit 1; }

# Pre-compute the colours from the known target (and shader) while the OLD
# wallpaper is still showing (near-instant when cached), so the crossfade and
# the colour change fire together in sync. Colours reflect the shadered output.
"$APPLY" --generate "$target" "$shader"

# Switch: start the new wallpaper as a second phonto instance (Hyprland
# crossfades the layers) AND apply the pre-computed colours at the same moment.
# setsid -f fully detaches phonto so it survives this script / the picker exiting.
old_pids=$(pgrep -x phonto || true)
if [[ -n "$shader" && -f "$shader" ]]; then
    setsid -f "$PHONTO" "$target" --shader "$shader" >/dev/null 2>&1
else
    setsid -f "$PHONTO" "$target" >/dev/null 2>&1
fi
"$APPLY" --apply

# Let the new wallpaper fade in, then drop the old instance (it fades out).
sleep 1.2
[[ -n "$old_pids" ]] && kill $old_pids 2>/dev/null || true
