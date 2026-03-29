#!/usr/bin/env bash

set -e

CONFIG_DIR="./configs"
SCR_DIR="./scr"
PKG_LIST="./packages.txt"
USER_NAME=$(whoami)
USER_HOME=$(eval echo "~$USER_NAME")
USER_CONFIG="$USER_HOME/.config"
USER_SCR="$USER_HOME/scr"

if [[ ! -f "$PKG_LIST" ]]; then
    echo "[!] packages.txt not found!"
    exit 1
fi

sed -i '1s/^\xEF\xBB\xBF//' "$PKG_LIST"
sed -i 's/[[:space:]]*$//' "$PKG_LIST"
sed -i '/^$/d' "$PKG_LIST"
mapfile -t PKGS < "$PKG_LIST"
sudo pacman -Syu --needed --noconfirm "${PKGS[@]}"

if [[ ! -d "$CONFIG_DIR" ]]; then
    echo "configs folder dont fucking exist pal"
    exit 1
fi

if [[ ! -d "$SCR_DIR" ]]; then
    echo "scr folder dont fucking exist pal"
    exit 1
fi

if [[ -f "$CONFIG_DIR/waybar/mediaplayer.sh" ]]; then
    chmod +x "$CONFIG_DIR/waybar/mediaplayer.sh"
fi

if compgen -G "$SCR_DIR/ConfigColors/*" > /dev/null; then
    chmod +x "$SCR_DIR/ConfigColors/"*
fi

mkdir -p "$USER_CONFIG"
mkdir -p "$USER_SCR"

cp -rT "$CONFIG_DIR" "$USER_CONFIG"
cp -rT "$SCR_DIR" "$USER_SCR"

chown -R "$USER_NAME":"$USER_NAME" "$USER_CONFIG"
chown -R "$USER_NAME":"$USER_NAME" "$USER_SCR"

if ! command -v yay >/dev/null 2>&1; then
    echo "[*] yay not found, installing..."
    cd /tmp
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
fi

yay -S --noconfirm vesktop
yay -S --noconfirm steam

mkdir -p "$USER_HOME/.local/share/applications"

xdg-mime default com.github.maoschanz.drawing.desktop image/png
xdg-mime default com.github.maoschanz.drawing.desktop image/jpeg
xdg-mime default com.github.maoschanz.drawing.desktop image/webp
xdg-mime default com.github.maoschanz.drawing.desktop image/gif
xdg-mime default com.github.maoschanz.drawing.desktop image/svg+xml
xdg-mime default nvim.desktop text/plain
xdg-mime default nvim.desktop text/markdown
xdg-mime default nvim.desktop application/json
xdg-mime default nvim.desktop application/x-shellscript
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/x-matroska
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/avi
xdg-mime default mpv.desktop video/mpeg

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$SCRIPT_DIR/applications"

if [[ -d "$APP_DIR" ]]; then
    echo "[*] Processing AppImages in $APP_DIR..."

    for appimage in "$APP_DIR"/*.AppImage; do
        [[ -e "$appimage" ]] || continue

        filename=$(basename "$appimage")
        name="${filename%.AppImage}"
        appimage_path="$(realpath "$appimage")"

        desktop_file="$USER_HOME/.local/share/applications/$name.desktop"

        cat > "$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Name=$name
Exec=$appimage_path
Icon=$appimage_path
Terminal=false
Categories=Utility;
EOF

        echo "[+] Registered AppImage: $name → $appimage_path"
    done

    update-desktop-database "$USER_HOME/.local/share/applications" 2>/dev/null || true
else
    echo "[!] ./applications folder not found!"
fi



sudo sed -i 's/Arch Linux/davos/g' /etc/os-release
sudo sed -i 's/Arch Linux/davos/g' /usr/lib/os-release

if [[ -f /etc/lsb-release ]]; then
    sudo sed -i 's/Arch/davos/g' /etc/lsb-release
fi
