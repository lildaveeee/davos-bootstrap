
#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
STATE_FILE="$DIR/state.txt"

CHOICE=$(printf "Music\nCustom" | dmenu -p "Choose mode:")

[ -z "$CHOICE" ] && exit 0

{
    echo "CHOICE=$CHOICE"
} > "$STATE_FILE"

