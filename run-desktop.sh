#!/bin/bash
export DISPLAY=:1
LOG_DIR="/home/kconger867/chrome-web/logs"
mkdir -p "$LOG_DIR"

# 1. Clean up old locks
sudo mkdir -p /tmp/.X11-unix && sudo chmod 1777 /tmp/.X11-unix
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true

# 2. Ensure dbus is running
sudo service dbus start >/dev/null 2>&1 || true

# 3. Ensure XFCE default panel & settings exist
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml
if [ ! -s ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml ] && [ -f /etc/xdg/xfce4/panel/default.xml ]; then
  cp -f /etc/xdg/xfce4/panel/default.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
fi

# 4. Start Xvfb (Virtual Framebuffer at 1600x900)
Xvfb :1 -screen 0 1600x900x24 -ac > "$LOG_DIR/xvfb.log" 2>&1 &
sleep 1

# Disable screensaver & screen blanking
xset s off -dpms s noblank 2>/dev/null || true

# 5. Start XFCE4 Desktop Session
dbus-launch --exit-with-session startxfce4 > "$LOG_DIR/xfce4.log" 2>&1 &
sleep 2

# 6. Start x11vnc
x11vnc -display :1 -forever -shared -nopw -rfbport 5900 -quiet > "$LOG_DIR/x11vnc.log" 2>&1 &
sleep 1

# 7. Start websockify (noVNC web interface on 8080)
websockify --web /usr/share/novnc 8080 localhost:5900 > "$LOG_DIR/websockify.log" 2>&1 &
sleep 1

# 8. Start cloudflared tunnel
rm -f /home/kconger867/chrome-web/url.txt "$LOG_DIR/cloudflared.log"
/home/kconger867/chrome-web/cloudflared tunnel --edge-ip-version 4 --protocol http2 --url http://localhost:8080 > "$LOG_DIR/cloudflared.log" 2>&1 &

(
  for i in {1..30}; do
    URL=$(grep -o "https://[a-zA-Z0-9-]*\.trycloudflare\.com" "$LOG_DIR/cloudflared.log" 2>/dev/null | head -n 1)
    if [ -n "$URL" ]; then
      echo "$URL" > /home/kconger867/chrome-web/url.txt
      break
    fi
    sleep 1
  done
) &

# Keep script running to monitor session
wait
