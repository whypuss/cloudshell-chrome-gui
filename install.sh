#!/bin/bash
set -e
echo "=== Installing Chrome Web GUI dependencies ==="
mkdir -p ~/.cloudshell && touch ~/.cloudshell/no-apt-get-warning

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME="$HOME"

mkdir -p "$DIR"
cd "$DIR"

# 1. Download Google Chrome deb if missing
if [ ! -f "$DIR/google-chrome-stable.deb" ]; then
  echo "Downloading Google Chrome deb..."
  curl -sSL -o "$DIR/google-chrome-stable.deb" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
fi

# 2. Download cloudflared binary if missing
if [ ! -f "$DIR/cloudflared" ]; then
  echo "Downloading cloudflared binary..."
  curl -sSL -o "$DIR/cloudflared" https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
  chmod +x "$DIR/cloudflared"
fi

# 3. Install system packages
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends \
  "$DIR/google-chrome-stable.deb" \
  xvfb x11vnc novnc websockify \
  xfce4-session xfwm4 xfce4-panel thunar xfdesktop4 xfce4-terminal mousepad dbus-x11 \
  fonts-noto-cjk scrot wmctrl xdotool openbox tint2 openssh-client

# 4. Configure noVNC defaults: auto-connect & auto-scale
sudo sed -i "s/getConfigVar('autoconnect', false)/getConfigVar('autoconnect', true)/" /usr/share/novnc/app/ui.js
sudo sed -i "s/UI.initSetting('resize', 'off')/UI.initSetting('resize', 'scale')/" /usr/share/novnc/app/ui.js
sudo ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# 5. Setup Desktop icons (for XFCE mode)
mkdir -p "$USER_HOME/Desktop"
cp /usr/share/applications/google-chrome.desktop "$USER_HOME/Desktop/" 2>/dev/null || true
cp /usr/share/applications/thunar.desktop "$USER_HOME/Desktop/" 2>/dev/null || true
cp /usr/share/applications/xfce4-terminal.desktop "$USER_HOME/Desktop/" 2>/dev/null || true
sed -i 's|^Exec=/usr/bin/google-chrome-stable.*|Exec=/usr/bin/google-chrome-stable --no-sandbox --test-type --disable-dev-shm-usage --disable-gpu --disable-session-crashed-bubble --password-store=basic --no-first-run --no-default-browser-check %U|g' "$USER_HOME/Desktop/google-chrome.desktop" 2>/dev/null || true
sudo sed -i 's|^Exec=/usr/bin/google-chrome-stable.*|Exec=/usr/bin/google-chrome-stable --no-sandbox --test-type --disable-dev-shm-usage --disable-gpu --disable-session-crashed-bubble --password-store=basic --no-first-run --no-default-browser-check %U|g' /usr/share/applications/google-chrome.desktop 2>/dev/null || true
chmod +x "$USER_HOME"/Desktop/*.desktop 2>/dev/null || true
gio set "$USER_HOME"/Desktop/*.desktop metadata::trusted true 2>/dev/null || true

# 6. Setup tint2 config
mkdir -p "$USER_HOME/.config/tint2"
if [ -f "$DIR/config/tint2rc" ]; then
  cp -f "$DIR/config/tint2rc" "$USER_HOME/.config/tint2/tint2rc"
elif [ -f "$DIR/tint2rc" ]; then
  cp -f "$DIR/tint2rc" "$USER_HOME/.config/tint2/tint2rc"
fi

# 7. Setup XFCE default panel
mkdir -p "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
if [ ! -s "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml" ] && [ -f /etc/xdg/xfce4/panel/default.xml ]; then
  cp -f /etc/xdg/xfce4/panel/default.xml "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
fi

# 8. Create global command shortcuts in /usr/local/bin
sudo ln -sf "$DIR/quick.sh" /usr/local/bin/chrome
sudo ln -sf "$DIR/quick-desktop.sh" /usr/local/bin/desktop
chmod +x "$DIR"/*.sh 2>/dev/null || true

echo "=== Installation complete ==="
