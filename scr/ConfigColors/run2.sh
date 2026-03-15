#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(dirname "$(realpath "$0")")"
STATE_FILE="$BASE_DIR/state.txt"
RUN1="$BASE_DIR/run.sh"

WALL_DIR="$HOME/Pictures/Wallpapers"
SELECTED_WALL="$WALL_DIR/selected.jpg"

mkdir -p "$WALL_DIR"

get_mode() {
    if [ -f "$STATE_FILE" ]; then
        grep '^CHOICE=' "$STATE_FILE" | cut -d= -f2
    else
        echo ""
    fi
}

# Start swww-daemon if not running
if ! pgrep -x swww-daemon >/dev/null; then
    swww-daemon & sleep 1
fi

apply_wallpaper() {
    if [ -f "$SELECTED_WALL" ]; then
        swww img "$SELECTED_WALL"
    fi
}

# Apply wallpaper immediately
apply_wallpaper

last_mode="$(get_mode)"

while true; do
    current_mode="$(get_mode)"

    # Switch back to run.sh when mode becomes Music
    if [ "$current_mode" = "Music" ] && [ "$last_mode" != "Music" ]; then
        exec "$RUN1"
    fi

    last_mode="$current_mode"
    sleep 1
done
