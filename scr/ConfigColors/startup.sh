
#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
STATE_FILE="$DIR/state.txt"

if [ ! -f "$STATE_FILE" ]; then
    echo "CHOICE=Music" > "$STATE_FILE"
    echo "WALLPAPER=" >> "$STATE_FILE"
    exit 0
fi

CURRENT_CHOICE=$(grep '^CHOICE=' "$STATE_FILE" | cut -d= -f2)
CURRENT_WALL=$(grep '^WALLPAPER=' "$STATE_FILE" | cut -d= -f2)

if [ "$CURRENT_CHOICE" = "Music" ]; then
    NEW_CHOICE="Custom"
else
    NEW_CHOICE="Music"
fi

{
    echo "CHOICE=$NEW_CHOICE"
    echo "WALLPAPER=$CURRENT_WALL"
} > "$STATE_FILE"

