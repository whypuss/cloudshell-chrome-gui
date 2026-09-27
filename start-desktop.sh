#!/bin/bash
DIR="/home/kconger867/chrome-web"

# Stop any conflicting sessions
tmux kill-session -t desktop-gui 2>/dev/null || true
tmux kill-session -t chrome-gui 2>/dev/null || true
killall -9 Xvfb x11vnc websockify cloudflared xfce4-session openbox tint2 2>/dev/null || true
sleep 1

# Start in detached tmux session
tmux new-session -d -s desktop-gui "bash $DIR/run-desktop.sh"
echo "XFCE Desktop session started in background (tmux session: desktop-gui)."
