#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON_FILE="$SCRIPT_DIR/dominant_color.json"
STYLE_FILE="$HOME/.config/vesktop/themes/system24.theme.css"
hex="$(jq -r '.dominant_color' "$JSON_FILE")"
cp "$STYLE_FILE" "$STYLE_FILE.bak"
sed -E -i \
  "s|^(\s*--active:\s*)#[0-9A-Fa-f]{3,8};|\1$hex;|" \
  "$STYLE_FILE"

