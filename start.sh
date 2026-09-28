#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmux kill-session -t chrome-gui 2>/dev/null || true
tmux kill-session -t desktop-gui 2>/dev/null || true
killall -9 websockify x11vnc openbox Xvfb chrome google-chrome cloudflared 2>/dev/null || true
pkill -f "a.pinggy.io" 2>/dev/null || true
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 "$DIR/url.txt" "$DIR/url-backup.txt" 2>/dev/null || true
rm -f ~/.config/google-chrome/Singleton* 2>/dev/null || true
sleep 1

tmux new-session -d -s chrome-gui "bash $DIR/run.sh"
echo "Chrome GUI started in tmux session 'chrome-gui'."
