#!/bin/bash
tmux kill-session -t chrome-gui 2>/dev/null || true
killall -9 websockify x11vnc openbox Xvfb chrome google-chrome 2>/dev/null || true
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true
sleep 1

tmux new-session -d -s chrome-gui "/home/kconger867/chrome-web/run.sh"
echo "Chrome GUI started in tmux session 'chrome-gui'."
