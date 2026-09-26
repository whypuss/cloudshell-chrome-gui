#!/bin/bash
if tmux has-session -t chrome-gui 2>/dev/null; then
  echo "✅ Chrome Web GUI 目前正在運行中 (Running)"
  echo ""
  PUBLIC_URL=$(cat /home/kconger867/chrome-web/url.txt 2>/dev/null)
  if [ -n "$PUBLIC_URL" ]; then
    echo "🌐 專屬公開連線網址（完整支援 WebSocket，點擊即可直連）："
    echo "$PUBLIC_URL"
  else
    echo "正在建立公開連線通道，請稍後幾秒再次執行此腳本..."
  fi
  echo ""
  echo "備用通道（Cloud Shell 內建預覽）："
  if which cloudshell >/dev/null 2>&1; then
    cloudshell get-web-preview-url --port 8080 2>/dev/null
  fi
else
  echo "❌ Chrome Web GUI 目前未啟動 (Stopped)"
  echo "提示：您可以執行 ~/chrome-web/start.sh 來啟動"
fi
