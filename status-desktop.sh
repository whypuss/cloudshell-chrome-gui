#!/bin/bash
DIR="/home/kconger867/chrome-web"
if tmux has-session -t desktop-gui 2>/dev/null; then
  echo "✅ XFCE 完整桌面目前正在運行中 (Running)"
  echo ""
  PUBLIC_URL=$(cat "$DIR/url.txt" 2>/dev/null)
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
  echo "❌ XFCE 完整桌面目前未啟動 (Stopped)"
  echo "提示：您可以執行 ~/chrome-web/start-desktop.sh 或輸入 'desktop' 來啟動"
fi
