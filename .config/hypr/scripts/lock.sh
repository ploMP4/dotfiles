#!/bin/bash

PHONTO=/home/plo/sandbox/phonto/target/release/phonto
CURRENT=$HOME/.cache/phonto/current

WALLPAPER=$(cat "$CURRENT" 2>/dev/null)
if [[ -n "$WALLPAPER" && -f "$WALLPAPER" ]]; then
    "$PHONTO" --layer overlay "$WALLPAPER" &
else
    "$PHONTO" --layer overlay --rand &
fi
OVERLAY_PID=$!
sleep 0.3

hyprlock

kill "$OVERLAY_PID" 2>/dev/null
pkill -f "phonto --layer overlay" 2>/dev/null
