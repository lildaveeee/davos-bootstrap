
#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
STATE_FILE="$DIR/state.txt"

if [ ! -f "$STATE_FILE" ]; then
    echo "CHOICE=Music" > "$STATE_FILE"
    exit 0
fi

CURRENT=$(grep '^CHOICE=' "$STATE_FILE" | cut -d= -f2)

if [ "$CURRENT" = "Music" ]; then
    echo "CHOICE=Custom" > "$STATE_FILE"
else
    echo "CHOICE=Music" > "$STATE_FILE"
fi

