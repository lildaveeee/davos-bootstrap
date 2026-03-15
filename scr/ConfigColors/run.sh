
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(dirname "$(realpath "$0")")"
IMAGE_DIR="$BASE_DIR/images"
BACKGROUND_DIR="$BASE_DIR/backgrounds"
STATE_FILE="$BASE_DIR/state.txt"
RUN2="$BASE_DIR/run2.sh"

ALBUM_ART_IMAGE="$IMAGE_DIR/albumArt.jpg"
TEMP_ART="$IMAGE_DIR/albumArt.tmp.jpg"
RESIZED_ART="$IMAGE_DIR/albumArt.resized.jpg"
RES_WIDTH=2560
RES_HEIGHT=1440

mkdir -p "$IMAGE_DIR" "$BACKGROUND_DIR"

if [ -f "$STATE_FILE" ]; then
    MODE=$(grep '^CHOICE=' "$STATE_FILE" | cut -d= -f2)

    if [ "$MODE" = "Custom" ]; then
        pkill -f "swww-daemon" || true
        pkill -f "magick" || true
        pkill -f "convert" || true

        pkill -P $$ || true

        exec "$RUN2"
    fi
fi

get_last_modified_time() {
  if [ -f "$ALBUM_ART_IMAGE" ]; then
    stat --format=%Y "$ALBUM_ART_IMAGE" 2>/dev/null
  else
    echo 0
  fi
}

previous_timestamp=$(get_last_modified_time)

if command -v swww-daemon &>/dev/null; then
  if ! pgrep -x swww-daemon &>/dev/null; then
    swww-daemon & sleep 1
  fi
fi

fetch_album_art() {
  ART_URL=$(playerctl --player=spotify metadata mpris:artUrl || true)

  if [ -n "$ART_URL" ]; then
    if [[ "$ART_URL" == file://* ]]; then
      cp "${ART_URL#file://}" "$TEMP_ART"
    else
      curl -sL "$ART_URL" -o "$TEMP_ART"
    fi
  else
    rmpc albumart --output "$TEMP_ART" || true
  fi

  if [ ! -s "$TEMP_ART" ]; then
    rm -f "$TEMP_ART"
    return 1
  fi

  convert "$TEMP_ART" -resize 600x600\! "$RESIZED_ART"
  rm -f "$TEMP_ART"

  if [ -f "$ALBUM_ART_IMAGE" ] && cmp -s "$ALBUM_ART_IMAGE" "$RESIZED_ART"; then
    rm -f "$RESIZED_ART"
    return 0
  fi

  mv "$RESIZED_ART" "$ALBUM_ART_IMAGE"
}

generate_wallpaper() {
  album_image="$ALBUM_ART_IMAGE"
  background_image="$BACKGROUND_DIR/background.jpg"
  blurred_image="$BACKGROUND_DIR/blurred_album.jpg"
  magick "$album_image" -resize "${RES_WIDTH}x${RES_HEIGHT}^" -gravity center -crop "${RES_WIDTH}x${RES_HEIGHT}+0+0" +repage -blur 0x10 "$blurred_image"
  magick "$blurred_image" "$album_image" -geometry +$(( (RES_WIDTH - 600) / 2 ))+$(( (RES_HEIGHT - 600) / 2 )) -composite "$background_image"
}

while true; do
  fetch_album_art || true
  current_timestamp=$(get_last_modified_time)
  if [ "$current_timestamp" -ne "$previous_timestamp" ]; then
    generate_wallpaper
    BACKGROUND_IMAGE="$BACKGROUND_DIR/background.jpg"
    ABS_PATH="$(realpath "$BACKGROUND_IMAGE")"
    if [ -f "$ABS_PATH" ]; then
      swww img "$ABS_PATH"
      previous_timestamp="$current_timestamp"
    else
      exit 1
    fi
  fi
  sleep 2
done

