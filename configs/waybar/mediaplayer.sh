#!/bin/sh

escape_markup() {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

state=$(playerctl --player=spotify status 2>/dev/null)
artist=$(playerctl --player=spotify metadata artist 2>/dev/null | escape_markup)
title=$(playerctl --player=spotify metadata title 2>/dev/null | escape_markup)

[ -z "$title" ] && exit 0

if [ "$state" = "Playing" ]; then
    echo "$artist - $title"
    exit 0
fi

if [ "$state" = "Paused" ]; then
    echo " $artist - $title"
    exit 0
fi

exit 0
