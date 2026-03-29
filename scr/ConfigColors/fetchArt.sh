
#!/bin/bash

set -euo pipefail

if [ -z "$1" ]; then
    echo "Error: No directory provided for saving images."
    exit 1
fi

IMAGE_DIR="$1"
mkdir -p "$IMAGE_DIR"

CURRENT_ART="$IMAGE_DIR/albumArt.jpg"
TEMP_ART="$IMAGE_DIR/albumArt.tmp.jpg"
RESIZED_ART="$IMAGE_DIR/albumArt.resized.jpg"

ART_URL=$(playerctl --player=spotify metadata mpris:artUrl || true)

if [ -z "$ART_URL" ]; then
    echo "Error: Could not retrieve album art URL from Spotify."
    exit 1
fi

if [[ "$ART_URL" == file://* ]]; then
    cp "${ART_URL#file://}" "$TEMP_ART"
else
    curl -sL "$ART_URL" -o "$TEMP_ART"
fi

if [ ! -s "$TEMP_ART" ]; then
    echo "Error: Failed to download album art."
    rm -f "$TEMP_ART"
    exit 1
fi

convert "$TEMP_ART" -resize 600x600\! "$RESIZED_ART"
rm -f "$TEMP_ART"

if [ -f "$CURRENT_ART" ] && cmp -s "$CURRENT_ART" "$RESIZED_ART"; then
    echo "Album art is already up-to-date."
    rm "$RESIZED_ART"
    exit 0
fi

mv "$RESIZED_ART" "$CURRENT_ART"
echo "Album art updated and resized at: $CURRENT_ART"

exit 0

