#!/bin/bash
tmux kill-session -t chrome-gui 2>/dev/null || true
killall -9 websockify x11vnc openbox Xvfb chrome google-chrome cloudflared 2>/dev/null || true
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 /home/kconger867/chrome-web/url.txt 2>/dev/null || true
echo "Chrome GUI stopped."
