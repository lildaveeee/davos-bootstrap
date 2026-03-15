
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(dirname "$(realpath "$0")")"
STATE_FILE="$BASE_DIR/state.txt"
WALL_DIR="$HOME/Pictures/Wallpapers"

mkdir -p "$WALL_DIR"

CHOICE=$(find "$WALL_DIR" -type f | dmenu -p "Select wallpaper:")
[ -z "$CHOICE" ] && exit 0

{
    echo "CHOICE=Custom"
    echo "WALLPAPER=$CHOICE"
} > "$STATE_FILE"
