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
sudo apt-get install -y --no-install-recommends \
  "$DIR/google-chrome-stable.deb" \
  xvfb x11vnc novnc websockify \
  xfce4-session xfwm4 xfce4-panel thunar xfdesktop4 xfce4-terminal mousepad dbus-x11 \
  fonts-noto-cjk scrot wmctrl xdotool openbox tint2

# Configure noVNC defaults: auto-connect & auto-scale
sudo sed -i "s/getConfigVar('autoconnect', false)/getConfigVar('autoconnect', true)/" /usr/share/novnc/app/ui.js
sudo sed -i "s/UI.initSetting('resize', 'off')/UI.initSetting('resize', 'scale')/" /usr/share/novnc/app/ui.js
sudo ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Setup Desktop icons
mkdir -p /home/kconger867/Desktop
cp /usr/share/applications/google-chrome.desktop /home/kconger867/Desktop/ 2>/dev/null || true
cp /usr/share/applications/thunar.desktop /home/kconger867/Desktop/ 2>/dev/null || true
cp /usr/share/applications/xfce4-terminal.desktop /home/kconger867/Desktop/ 2>/dev/null || true
sed -i 's|^Exec=/usr/bin/google-chrome-stable.*|Exec=/usr/bin/google-chrome-stable --no-sandbox --test-type --disable-dev-shm-usage --disable-gpu --disable-session-crashed-bubble --password-store=basic --no-first-run --no-default-browser-check %U|g' /home/kconger867/Desktop/google-chrome.desktop 2>/dev/null || true
sudo sed -i 's|^Exec=/usr/bin/google-chrome-stable.*|Exec=/usr/bin/google-chrome-stable --no-sandbox --test-type --disable-dev-shm-usage --disable-gpu --disable-session-crashed-bubble --password-store=basic --no-first-run --no-default-browser-check %U|g' /usr/share/applications/google-chrome.desktop 2>/dev/null || true
chmod +x /home/kconger867/Desktop/*.desktop 2>/dev/null || true
gio set /home/kconger867/Desktop/*.desktop metadata::trusted true 2>/dev/null || true

# Setup XFCE default panel
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml
if [ ! -s ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml ] && [ -f /etc/xdg/xfce4/panel/default.xml ]; then
  cp -f /etc/xdg/xfce4/panel/default.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
fi

echo "=== Installation complete ==="
