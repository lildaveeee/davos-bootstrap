
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(dirname "$(realpath "$0")")"
STATE_FILE="$BASE_DIR/state.txt"
RUN1="$BASE_DIR/run.sh"
WALL_DIR="$HOME/Pictures/Wallpapers"

mkdir -p "$WALL_DIR"

if [ -f "$STATE_FILE" ]; then
    MODE=$(grep '^CHOICE=' "$STATE_FILE" | cut -d= -f2)
    if [ "$MODE" = "Music" ]; then
        pkill -f "swww-daemon" || true
        pkill -f "magick" || true
        pkill -f "convert" || true
        pkill -P $$ || true
        exec "$RUN1"
    fi
fi

if command -v swww-daemon &>/dev/null; then
  if ! pgrep -x swww-daemon &>/dev/null; then
    swww-daemon & sleep 1
  fi
fi

get_wallpapers() {
  find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | sort
}

dir_hash() {
  find "$WALL_DIR" -type f -printf "%T@ %p\n" | sha256sum | awk '{print $1}'
}

previous_hash="$(dir_hash)"
index=0

while true; do
  current_hash="$(dir_hash)"

  if [ "$current_hash" != "$previous_hash" ]; then
    previous_hash="$current_hash"
    index=0
  fi

  wallpapers=($(get_wallpapers))

  if [ ${#wallpapers[@]} -eq 0 ]; then
    sleep 5
    continue
  fi

  if [ "$index" -ge "${#wallpapers[@]}" ]; then
    index=0
  fi

  wp="${wallpapers[$index]}"
  abs="$(realpath "$wp")"

  if [ -f "$abs" ]; then
    swww img "$abs"
  fi

  index=$((index + 1))
  sleep 10
done

