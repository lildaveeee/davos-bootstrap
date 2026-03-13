
#!/bin/sh

escape_markup() {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

state=$(rmpc status | jq -r '.state')

artist=$(rmpc song | jq -r '.metadata.artist // empty' | escape_markup)
title=$(rmpc song | jq -r '.metadata.title // empty' | escape_markup)

[ -z "$title" ] && exit 0

if [ "$state" = "Play" ]; then
    echo "$artist - $title"
    exit 0
fi

if [ "$state" = "Pause" ]; then
    echo " $artist - $title"
    exit 0
fi

exit 0

