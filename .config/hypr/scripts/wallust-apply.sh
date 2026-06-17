#!/bin/bash
# Derive a colour palette from a (video) wallpaper and apply it across the
# desktop (ghostty, hyprland, wofi, waybar, p10k, tmux, neovim, stochos).
#
# Usage:
#   wallust-apply.sh [SOURCE]      generate from SOURCE (or phonto's current) AND apply
#   wallust-apply.sh --generate SOURCE   only compute + write the colour files
#   wallust-apply.sh --apply             only trigger the live reloads/animations
#   wallust-apply.sh --prewarm-all       cache every wallpaper's palette (no apply)
#
# Splitting generate/apply lets the picker do the slow work (ffmpeg + wallust)
# up front, then fire the wallpaper crossfade and the colour change together so
# they stay in sync. The palette derivation itself lives in wallust-colors.py.
set -euo pipefail

# Launched from hyprland the login shell rc is not sourced, so ~/.cargo/bin
# (where wallust lives) is missing from PATH. Add it so it matches a manual run.
export PATH="$HOME/.cargo/bin:$PATH"

CURRENT="$HOME/.cache/phonto/current"
FRAME="$HOME/.cache/wallust/frame.png"
RAW="$HOME/.cache/wallust/raw.conf"
PALETTE_CACHE="$HOME/.cache/wallust/palettes"
WALLPAPER_DIR="$HOME/dotfiles/wallpapers/animated"
GHOSTTY_COLORS="$HOME/.config/ghostty/wallust"
ACCENT_FILE="$HOME/.cache/wallust/accent"
TMUX_COLORS="$HOME/.cache/wallust/tmux.conf"
COLORS_PY="$HOME/.config/hypr/scripts/wallust-colors.py"
mkdir -p "$(dirname "$FRAME")" "$PALETTE_CACHE"

# Cache file holding wallust's raw output for a given wallpaper, keyed by path.
cache_path() { printf '%s/%s' "$PALETTE_CACHE" "$(printf '%s' "$1" | md5sum | cut -d' ' -f1)"; }

# Compute wallust's raw palette for SRC into the cache (frame extract + wallust),
# unless already cached. Touches only $FRAME, $RAW and the cache — never the live
# ghostty file — so it is safe to run in the background for pre-warming.
build_cache() {
    local src="$1" cache t generated=false
    cache="$(cache_path "$src")"
    [[ -f "$cache" ]] && return 0
    ffmpeg -y -ss 00:00:02 -i "$src" -frames:v 1 -vf "scale=720:-1" "$FRAME" 2>/dev/null \
      || ffmpeg -y -i "$src" -frames:v 1 -vf "scale=720:-1" "$FRAME" 2>/dev/null \
      || return 1
    # The threshold strongly affects which background wallust picks: a strict one
    # favours the salient tone, a low one collapses to the desaturated bulk colour
    # (e.g. forest green instead of cabin amber). Start strict, step down only if
    # a frame has too few distinct colours.
    for t in 20 11 5 2 1; do
        if wallust run -q -s -t "$t" "$FRAME" 2>/dev/null; then
            generated=true
            break
        fi
    done
    "$generated" || return 1
    cp "$RAW" "$cache" 2>/dev/null || true
}

# Resolve the wallpaper when no explicit source is given (full mode at login).
# 'current' persists across runs and still holds the PREVIOUS wallpaper until the
# new phonto rewrites it, so wait for the content to change first.
resolve_src() {
    local src="" old
    old="$(cat "$CURRENT" 2>/dev/null || true)"
    for _ in {1..20}; do
        if [[ -s "$CURRENT" ]]; then
            src="$(cat "$CURRENT")"
            [[ -n "$src" && "$src" != "$old" ]] && break
        fi
        sleep 0.3
    done
    [[ -z "$src" || "$src" == "$old" ]] && src="$(cat "$CURRENT" 2>/dev/null || true)"
    printf '%s' "$src"
}

# Compute the palette and write all the per-app colour files. No live reloads.
# A previously-seen wallpaper is a cache hit, skipping ffmpeg + wallust.
generate() {
    local src="$1" cache
    [[ -z "$src" ]] && { echo "wallust-apply: no wallpaper source found" >&2; return 1; }
    cache="$(cache_path "$src")"
    [[ -f "$cache" ]] || build_cache "$src" \
        || { echo "wallust-apply: could not build palette from $src" >&2; return 1; }
    cp "$cache" "$GHOSTTY_COLORS"
    python3 "$COLORS_PY" 2>/dev/null || true
}

# Trigger the live reloads/animations using the already-written colour files.
apply() {
    pkill -SIGUSR2 ghostty 2>/dev/null || true   # ghostty: reload config
    hyprctl reload >/dev/null 2>&1 || true        # hyprland: re-read border accent
    pkill -SIGUSR2 waybar 2>/dev/null || true     # waybar: reload style

    # neovim: animate every running instance to the new accent (lumonight's
    # :LumonightAnimate); fall back to re-applying the scheme (snap) otherwise.
    if command -v nvim >/dev/null 2>&1; then
        local sock
        for sock in "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/nvim.*; do
            [[ -S "$sock" ]] || continue
            nvim --server "$sock" --remote-expr \
                'exists(":LumonightAnimate") == 2 ? execute("LumonightAnimate") : execute("colorscheme " . get(g:, "colors_name", "lumonight"))' \
                >/dev/null 2>&1 || true
        done
    fi

    # tmux: live-apply the accent overrides to a running server (no-op if none).
    if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
        tmux source-file "$TMUX_COLORS" >/dev/null 2>&1 || true
    fi

    # tms (tmux sessionizer): persist picker colours for the next popup.
    if command -v tms >/dev/null 2>&1; then
        local primary secondary
        primary=$(sed -n 1p "$ACCENT_FILE" 2>/dev/null)
        secondary=$(sed -n 2p "$ACCENT_FILE" 2>/dev/null)
        if [[ -n "$primary" ]]; then
            tms config --picker-highlight-color "$primary" \
                       --picker-border-color "$primary" \
                       --picker-prompt-color "$primary" \
                       ${secondary:+--picker-info-color "$secondary"} >/dev/null 2>&1 || true
        fi
    fi
}

main() {
    case "${1:-}" in
        --generate) [[ -n "${2:-}" ]] && generate "$2" ;;
        --apply)    apply ;;
        --prewarm-all)
            # Background job at login: build only the missing cache entries;
            # never touches the live colours. Afterwards every pick is a hit.
            local f
            for f in "$WALLPAPER_DIR"/*; do
                [[ -f "$f" ]] && build_cache "$f" >/dev/null 2>&1 || true
            done
            ;;
        *)
            # Full run: generate from the given source (or phonto's current) and apply.
            local src="${1:-}"
            [[ -z "$src" ]] && src="$(resolve_src)"
            generate "$src" && apply
            ;;
    esac
}

main "$@"
