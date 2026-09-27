#!/bin/bash
export DISPLAY=:1
sudo mkdir -p /tmp/.X11-unix && sudo chmod 1777 /tmp/.X11-unix
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true

LOG_DIR="/home/kconger867/chrome-web/logs"
mkdir -p "$LOG_DIR"

# 1. Start Xvfb
Xvfb :1 -screen 0 1600x900x24 -ac > "$LOG_DIR/xvfb.log" 2>&1 &
sleep 1

# 2. Start Openbox
openbox > "$LOG_DIR/openbox.log" 2>&1 &
sleep 1

# 3. Set nice desktop wallpaper background
xsetroot -solid "#3b4252" 2>/dev/null || true

# 4. Start tint2 panel (clean top bar with launch & restore buttons)
tint2 > "$LOG_DIR/tint2.log" 2>&1 &
sleep 1

# 5. Start x11vnc
x11vnc -display :1 -forever -shared -nopw -rfbport 5900 -quiet > "$LOG_DIR/x11vnc.log" 2>&1 &
sleep 1

# 6. Start websockify
websockify --web /usr/share/novnc 8080 localhost:5900 > "$LOG_DIR/websockify.log" 2>&1 &
sleep 1

# 7. Start cloudflared tunnel
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

# 8. Start Chrome supervisor
while true; do
  sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' ~/.config/google-chrome/Default/Preferences 2>/dev/null || true
  
  google-chrome-stable \
    --no-sandbox \
    --test-type \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-session-crashed-bubble \
    --password-store=basic \
    --start-maximized \
    --no-first-run \
    --no-default-browser-check \
    "https://www.google.com" >> "$LOG_DIR/chrome.log" 2>&1
  sleep 2
done
