#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if tmux has-session -t chrome-gui 2>/dev/null; then
  echo "=========================================="
  echo "✅ Chrome Web GUI 目前正在運行中 (Running)"
  echo "=========================================="
  echo ""
  
  URL=$(cat "$DIR/url.txt" 2>/dev/null)
  BACKUP_URL=$(cat "$DIR/url-backup.txt" 2>/dev/null)

  if [ -n "$URL" ]; then
    BASE_URL=$(echo "$URL" | sed 's|/vnc.html.*||')
    echo "🌐 主要連線網址（Cloudflare 隧道，無使用時限）："
    echo "👉 ${BASE_URL}/vnc.html?autoconnect=true&resize=scale"
    echo ""
  fi

  if [ -n "$BACKUP_URL" ]; then
    B_BASE_URL=$(echo "$BACKUP_URL" | sed 's|/vnc.html.*||')
    echo "⚡ 備用連線網址（Pinggy 零延遲通道，若主要通道無法打開請點此）："
    echo "👉 ${B_BASE_URL}/vnc.html?autoconnect=true&resize=scale"
    echo ""
  fi

  if [ -z "$URL" ] && [ -z "$BACKUP_URL" ]; then
    echo "⏳ 正在驗證通道全球連線性中（約 5~10 秒），請稍後再次執行此指令..."
    echo ""
  else
    echo "💡 提示：點擊上方任一網址即可直開 Chrome，無需其他操作！"
    echo "💡 提醒：通道重啟後會生成隨機新網址（舊網址自動失效），請以此最新網址為準！"
    echo "⚠️ 注意：請勿使用 Cloud Shell 右上角「網頁預覽」，該預覽不支援 WebSocket 會永遠卡在連線中！"
  fi
  echo "=========================================="
else
  echo "❌ Chrome Web GUI 目前未啟動 (Stopped)"
  echo "提示：您可以輸入 'chrome' 或執行 $DIR/start.sh 來啟動"
fi
