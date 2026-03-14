
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON_FILE="$SCRIPT_DIR/dominant_color.json"
TOML_FILE="$HOME/.config/alacritty/alacritty.toml"
dominant_hex="$(jq -r '.dominant_color' "$JSON_FILE")"
sed -i -E \
  "s|^[[:space:]]*foreground[[:space:]]*=.*|foreground = \"${dominant_hex}\"|" \
  "$TOML_FILE"


