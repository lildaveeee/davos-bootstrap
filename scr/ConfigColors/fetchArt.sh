
#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No directory provided for saving images."
    exit 1
fi

IMAGE_DIR="$1"
mkdir -p "$IMAGE_DIR"

CURRENT_ART="$IMAGE_DIR/albumArt.jpg"
TEMP_ART="$IMAGE_DIR/albumArt.tmp.jpg"
RESIZED_ART="$IMAGE_DIR/albumArt.resized.jpg"

rmpc albumart --output "$TEMP_ART"
if [ $? -ne 0 ] || [ ! -s "$TEMP_ART" ]; then
    echo "Error: Failed to retrieve album art via rmpc."
    rm -f "$TEMP_ART"
    exit 1
fi

convert "$TEMP_ART" -resize 600x600\! "$RESIZED_ART"
rm -f "$TEMP_ART"

if [ -f "$CURRENT_ART" ]; then
    if cmp -s "$CURRENT_ART" "$RESIZED_ART"; then
        echo "Album art is already up-to-date."
        rm "$RESIZED_ART"
        exit 0
    fi
fi

mv "$RESIZED_ART" "$CURRENT_ART"
echo "Album art updated and resized at: $CURRENT_ART"

exit 0
