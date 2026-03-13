
#!/usr/bin/env bash

set -e

CONFIG_DIR="./configs"
PKG_LIST="./packages.txt"
USER_NAME=$(whoami)
USER_HOME=$(eval echo "~$USER_NAME")

if [[ ! -f "$PKG_LIST" ]]; then
    echo "[!] packages.txt not found!"
    exit 1
fi

sudo pacman -Syu --needed --noconfirm - < "$PKG_LIST"

if [[ ! -d "$CONFIG_DIR" ]]; then
    echo "configs folder dont fucking exist pal"
    exit 1
fi

cp -rT "$CONFIG_DIR" "$USER_HOME"
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME"

sudo sed -i 's/Arch Linux/davos/g' /etc/os-release

sudo sed -i 's/Arch Linux/davos/g' /usr/lib/os-release

if [[ -f /etc/lsb-release ]]; then
    sudo sed -i 's/Arch/davos/g' /etc/lsb-release
fi

