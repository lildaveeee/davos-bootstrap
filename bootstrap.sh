
#!/usr/bin/env bash

set -e

CONFIG_DIR="./configs"
PKG_LIST="./packages.txt"
USER_NAME=$(whoami)
USER_HOME=$(eval echo "~$USER_NAME")
USER_CONFIG="$USER_HOME/.config"

if [[ ! -f "$PKG_LIST" ]]; then
    echo "[!] packages.txt not found!"
    exit 1
fi

sudo pacman -Syu --needed --noconfirm - < "$PKG_LIST"

if [[ ! -d "$CONFIG_DIR" ]]; then
    echo "configs folder dont fucking exist pal"
    exit 1
fi

mkdir -p "$USER_CONFIG"

cp -rT "$CONFIG_DIR" "$USER_CONFIG"

chown -R "$USER_NAME":"$USER_NAME" "$USER_CONFIG"

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

sudo sed -i 's/Arch Linux/davos/g' /etc/os-release
sudo sed -i 's/Arch Linux/davos/g' /usr/lib/os-release

if [[ -f /etc/lsb-release ]]; then
    sudo sed -i 's/Arch/davos/g' /etc/lsb-release
fi

