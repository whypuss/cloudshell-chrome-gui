#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DISPLAY=:1
LOG_DIR="$DIR/logs"
mkdir -p "$LOG_DIR"
rm -f "$LOG_DIR/cloudflared.log" "$LOG_DIR/pinggy.log" 2>/dev/null || true

# 1. Clean up old locks
sudo mkdir -p /tmp/.X11-unix && sudo chmod 1777 /tmp/.X11-unix
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 "$DIR/url.txt" "$DIR/url-backup.txt" 2>/dev/null || true
rm -f ~/.config/google-chrome/Singleton* 2>/dev/null || true

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

# 8. Start Cloudflare Tunnel & Backup Tunnel
if [ -x "$DIR/cloudflared" ]; then
  "$DIR/cloudflared" tunnel --edge-ip-version 4 --protocol http2 --url http://localhost:8080 > "$LOG_DIR/cloudflared.log" 2>&1 &
fi

# Backup tunnel: Pinggy (Zero DNS delay fallback)
ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=30 -p 443 -R0:localhost:8080 a.pinggy.io > "$LOG_DIR/pinggy.log" 2>&1 &

# Background monitor: Extract Pinggy backup URL
(
  for i in {1..20}; do
    P_URL=$(grep -o "https://[a-zA-Z0-9.-]*\.link" "$LOG_DIR/pinggy.log" 2>/dev/null | head -n 1)
    if [ -n "$P_URL" ]; then
      echo "$P_URL" > "$DIR/url-backup.txt"
      break
    fi
    sleep 1
  done
) &

# Background monitor: Extract Cloudflare URL and strictly verify reachability before publishing
(
  CF_URL=""
  for i in {1..25}; do
    CF_URL=$(grep -o "https://[a-zA-Z0-9-]*\.trycloudflare\.com" "$LOG_DIR/cloudflared.log" 2>/dev/null | head -n 1)
    if [ -n "$CF_URL" ]; then
      break
    fi
    sleep 1
  done

  if [ -n "$CF_URL" ]; then
    # Wait until connection registration confirms edge handshake
    for i in {1..25}; do
      if grep -q "Registered tunnel connection" "$LOG_DIR/cloudflared.log" 2>/dev/null; then
        break
      fi
      sleep 1
    done

    # Probe DNS/HTTP reachability (prevents negative caching on user client)
    for i in {1..25}; do
      CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 "$CF_URL" 2>/dev/null || true)
      if [ "$CODE" = "200" ] || [ "$CODE" = "302" ]; then
        echo "$CF_URL" > "$DIR/url.txt"
        exit 0
      fi
      sleep 1
    done

    # Write URL after reasonable stabilization buffer
    echo "$CF_URL" > "$DIR/url.txt"
  fi
) &

# Keep script running to monitor session
wait
