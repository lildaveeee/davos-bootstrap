#!/bin/sh

BASE_DIR="$HOME/scr"
INSTALL_DIR="$BASE_DIR/applications"
FILE="Davos.Browser-0.1.0.AppImage"
URL="https://github.com/LilDaveeee/davos-browser/releases/latest/download/$FILE"
mkdir -p "$INSTALL_DIR"
curl -L -o "$INSTALL_DIR/$FILE" "$URL"
chmod +x "$INSTALL_DIR/$FILE"
DESKTOP_FILE="$HOME/.local/share/applications/davos-browser.desktop"
mkdir -p "$(dirname "$DESKTOP_FILE")"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Davos Browser
Exec=$INSTALL_DIR/$FILE
Icon=web-browser
Type=Application
Categories=Network;WebBrowser;
Terminal=false
EOF
