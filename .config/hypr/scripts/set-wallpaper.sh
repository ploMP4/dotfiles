#!/bin/bash
# Switch the wallpaper (with a crossfade) and re-theme the desktop to match.
# Reusable core shared by the wofi selector and the quickshell picker.
#
# Usage:
#   set-wallpaper.sh /path/to/wallpaper.mp4
#   set-wallpaper.sh --shuffle
set -euo pipefail
export PATH="$HOME/.cargo/bin:$PATH"

WALLPAPER_DIR="$HOME/dotfiles/wallpapers/animated"
PHONTO="/home/plo/sandbox/phonto/target/release/phonto"
APPLY="$HOME/.config/hypr/scripts/wallust-apply.sh"

target="${1:-}"
if [[ "$target" == "--shuffle" ]]; then
    target="$(find "$WALLPAPER_DIR" -type f \( -name '*.mp4' -o -name '*.mkv' -o -name '*.webm' -o -name '*.avi' -o -name '*.gif' \) | shuf -n1)"
fi
[[ -z "$target" || ! -f "$target" ]] && { echo "set-wallpaper: no such wallpaper: $target" >&2; exit 1; }

# Pre-compute the colors from the known target while the OLD wallpaper is still
# showing (near-instant when cached), so the crossfade and the color change can
# fire together in sync.
"$APPLY" --generate "$target"

# Switch: start the new wallpaper as a second phonto instance (Hyprland
# crossfades the layers) AND apply the pre-computed colors at the same moment.
# setsid -f fully detaches phonto so it survives this script / the picker exiting.
old_pids=$(pgrep -x phonto || true)
setsid -f "$PHONTO" "$target" >/dev/null 2>&1
"$APPLY" --apply

# Let the new wallpaper fade in, then drop the old instance (it fades out).
sleep 1.2
[[ -n "$old_pids" ]] && kill $old_pids 2>/dev/null || true
