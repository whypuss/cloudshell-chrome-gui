#!/bin/bash
echo "Stopping XFCE Desktop session..."
tmux kill-session -t desktop-gui 2>/dev/null || true
killall -9 Xvfb x11vnc websockify cloudflared xfce4-session xfwm4 xfdesktop4 xfce4-panel 2>/dev/null || true
rm -f /home/kconger867/chrome-web/url.txt
echo "XFCE Desktop session stopped."
