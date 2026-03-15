
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(dirname "$(realpath "$0")")"
STATE_FILE="$BASE_DIR/state.txt"

IMAGE_DIR="$BASE_DIR/images"
BACKGROUND_DIR="$BASE_DIR/backgrounds"

mkdir -p "$IMAGE_DIR" "$BACKGROUND_DIR"

ALBUM_ART_IMAGE="$IMAGE_DIR/albumArt.jpg"
TEMP_ART="$IMAGE_DIR/albumArt.tmp.jpg"
RESIZED_ART="$IMAGE_DIR/albumArt.resized.jpg"

RES_WIDTH=2560
RES_HEIGHT=1440

get_mode() {
    grep '^CHOICE=' "$STATE_FILE" | cut -d= -f2
}

get_wallpaper() {
    grep '^WALLPAPER=' "$STATE_FILE" | cut -d= -f2
}

# Start swww-daemon if needed
if ! pgrep -x swww-daemon >/dev/null; then
    swww-daemon & sleep 1
fi

# --- MUSIC MODE ---

fetch_album_art() {
    ART_URL=$(playerctl --player=spotify metadata mpris:artUrl || true)

    if [ -n "$ART_URL" ]; then
        if [[ "$ART_URL" == file://* ]]; then
            cp "${ART_URL#file://}" "$TEMP_ART"
        else
            curl -sL "$ART_URL" -o "$TEMP_ART"
        fi
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

generate_music_wallpaper() {
    album_image="$ALBUM_ART_IMAGE"
    background_image="$BACKGROUND_DIR/background.jpg"
    blurred_image="$BACKGROUND_DIR/blurred_album.jpg"

    magick "$album_image" -resize "${RES_WIDTH}x${RES_HEIGHT}^" \
        -gravity center -crop "${RES_WIDTH}x${RES_HEIGHT}+0+0" +repage \
        -blur 0x10 "$blurred_image"

    magick "$blurred_image" "$album_image" \
        -geometry +$(( (RES_WIDTH - 600) / 2 ))+$(( (RES_HEIGHT - 600) / 2 )) \
        -composite "$background_image"

    swww img "$background_image"
}

# --- CUSTOM MODE ---

apply_custom_wallpaper() {
    WALL=$(get_wallpaper)
    [ -z "$WALL" ] && return
    [ ! -f "$WALL" ] && return
    swww img "$WALL"
}

# --- MAIN LOOP ---

last_mode=""

while true; do
    mode="$(get_mode)"

    # Mode changed → react immediately
    if [ "$mode" != "$last_mode" ]; then
        if [ "$mode" = "Custom" ]; then
            apply_custom_wallpaper
        fi
    fi

    # Music mode runs continuously
    if [ "$mode" = "Music" ]; then
        fetch_album_art && generate_music_wallpaper
    fi

    last_mode="$mode"
    sleep 5
done

