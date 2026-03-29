#!/usr/bin/env bash

set -e

CONFIG_DIR="./configs"
SCR_DIR="./scr"
PKG_LIST="./packages.txt"
USER_NAME=$(whoami)
USER_HOME=$(eval echo "~$USER_NAME")
USER_CONFIG="$USER_HOME/.config"
USER_SCR="$USER_HOME/scr"
HYPR_CONF="./configs/hypr/hyprland/general.conf"

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
echo "[*] Detecting monitors using hyprctl..."

if [[ ! -f "$HYPR_CONF" ]]; then
    echo "[!] Hyprland config not found at $HYPR_CONF"
    exit 1
fi

mapfile -t MON_LINES < <(hyprctl monitors | grep -E "Monitor |availableModes")

MONITORS=()
CURRENT_MON=""
for line in "${MON_LINES[@]}"; do
    if [[ "$line" =~ ^Monitor ]]; then
        CURRENT_MON=$(echo "$line" | awk '{print $2}')
        MONITORS+=("$CURRENT_MON")
        declare -g "MODES_$CURRENT_MON"=""
    fi

    if [[ "$line" =~ availableModes ]]; then
        modes=$(echo "$line" | sed 's/availableModes: //')
        declare -g "MODES_$CURRENT_MON=$modes"
    fi
done

NEW_MONITOR_LINES=""
POS_X=0

for mon in "${MONITORS[@]}"; do
    modes_var="MODES_$mon"
    modes=${!modes_var}

    best=$(echo "$modes" | tr ' ' '\n' \
        | sed 's/x/ /; s/@/ /; s/Hz//' \
        | sort -k1,1nr -k3,3nr \
        | head -n 1)

    width=$(echo "$best" | awk '{print $1}')
    height=$(echo "$best" | awk '{print $2}')
    hz=$(echo "$best" | awk '{print $3}')

    NEW_MONITOR_LINES+="monitor=$mon, ${width}x${height}@${hz}, ${POS_X}x0, 1\n"

    POS_X=$((POS_X + width))
done

sed -i '/# MONITOR CONFIG/{:a; n; /^monitor=/d; ba}' "$HYPR_CONF"

printf "%b" "$NEW_MONITOR_LINES" | sed -i "/# MONITOR CONFIG/r /dev/stdin" "$HYPR_CONF"

echo "[+] Hyprland monitor configuration updated."

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
yay -S --noconfirm walt-git

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

APP_DIR="./applications"
TARGET_APP_DIR="$USER_HOME/.local/share/applications/AppImages"

mkdir -p "$TARGET_APP_DIR"
if [[ -d "$APP_DIR" ]]; then
    echo "[*] Processing AppImages in $APP_DIR..."

    for appimage in "$APP_DIR"/*.AppImage; do
        [[ -e "$appimage" ]] || continue

        filename=$(basename "$appimage")
        name="${filename%.AppImage}"

        cp "$appimage" "$TARGET_APP_DIR/$filename"
        chmod +x "$TARGET_APP_DIR/$filename"

        desktop_file="$USER_HOME/.local/share/applications/$name.desktop"

        cat > "$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Name=$name
Exec=$TARGET_APP_DIR/$filename
Icon=$TARGET_APP_DIR/$filename
Terminal=false
Categories=Utility;
EOF

        echo "[+] Installed AppImage: $name"
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
