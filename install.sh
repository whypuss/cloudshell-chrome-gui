#!/bin/bash
set -e
echo "=== Installing Chrome Web GUI dependencies ==="
mkdir -p ~/.cloudshell && touch ~/.cloudshell/no-apt-get-warning

DIR="/home/kconger867/chrome-web"
mkdir -p "$DIR"
cd "$DIR"

if [ ! -f "$DIR/google-chrome-stable.deb" ]; then
  echo "Downloading Google Chrome deb..."
  curl -sSL -o "$DIR/google-chrome-stable.deb" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
fi

sudo apt-get update -qq
sudo apt-get install -y "$DIR/google-chrome-stable.deb" xvfb x11vnc novnc websockify openbox fonts-noto-cjk scrot tint2 wmctrl xdotool

# Configure noVNC defaults: auto-connect & auto-scale
sudo sed -i "s/getConfigVar('autoconnect', false)/getConfigVar('autoconnect', true)/" /usr/share/novnc/app/ui.js
sudo sed -i "s/UI.initSetting('resize', 'off')/UI.initSetting('resize', 'scale')/" /usr/share/novnc/app/ui.js
sudo ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

echo "=== Installation complete ==="
