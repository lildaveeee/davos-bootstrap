
#!/usr/bin/env bash
set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON_FILE="$SCRIPT_DIR/dominant_color.json"
KITTY_CONF="$HOME/.config/kitty/kitty.conf"
dominant_hex="$(jq -r '.dominant_color' "$JSON_FILE")"
sed -i -E \
  "s|^foreground[[:space:]]+.*|foreground $dominant_hex|" \
  "$KITTY_CONF"
if pgrep -u "$USER" kitty &>/dev/null; then
  pkill -SIGUSR1 -u "$USER" kitty \
    && echo "colours reloaded"
else
  echo "cat is dead or doesnt exist"
fi
