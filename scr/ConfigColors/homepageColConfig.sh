
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON_FILE="$SCRIPT_DIR/dominant_color.json"
HTML_FILE="$SCRIPT_DIR/html/homepage.html"
hex="$(jq -r '.dominant_color' "$JSON_FILE")"
hex="${hex#\#}"
r=$((16#${hex:0:2}))
g=$((16#${hex:2:2}))
b=$((16#${hex:4:2}))

sed -i -E "/body \{/,/\}/ s|color:.*|color: rgba($r, $g, $b, 0.9);|" "$HTML_FILE"

sed -i -E "/\.search-box input \{/,/\}/ s|border:.*|border: 1px solid rgba($r, $g, $b, 0.9);|" "$HTML_FILE"

sed -i -E "/\.search-box input \{/,/\}/ s|color:.*|color: rgba($r, $g, $b, 0.9);|" "$HTML_FILE"

sed -i -E "/\.links a \{/,/\}/ s|color:.*|color: rgba($r, $g, $b, 0.9);|" "$HTML_FILE"

sed -i -E "/\.links a \{/,/\}/ s|border:.*|border: 1px solid rgba($r, $g, $b, 0.9);|" "$HTML_FILE"

echo "Updated homepage text colors and borders to rgba($r, $g, $b, 0.9)."
