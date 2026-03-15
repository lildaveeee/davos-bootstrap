
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

last_mode="$(get_mode)"

apply_wallpaper() {
    if [ -f "$SELECTED_WALL" ]; then
        swww img "$SELECTED_WALL"
    fi
}

apply_wallpaper

while true; do
    current_mode="$(get_mode)"

    if [ "$current_mode" = "MUSIC" ] && [ "$last_mode" != "MUSIC" ]; then
        pkill -f "swww-daemon" || true
        pkill -f "magick" || true
        pkill -f "convert" || true
        exec "$RUN1"
    fi

    last_mode="$current_mode"
    sleep 1
done

