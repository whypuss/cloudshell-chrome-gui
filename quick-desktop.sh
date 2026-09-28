#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "   🚀 XFCE 桌面一鍵快速啟動器"
echo "=========================================="

# 1. 檢查是否需要重新安裝套件
if ! which google-chrome-stable >/dev/null 2>&1 || ! which Xvfb >/dev/null 2>&1 || ! which startxfce4 >/dev/null 2>&1 || ! which websockify >/dev/null 2>&1 || [ ! -x "$DIR/cloudflared" ]; then
    echo "📦 偵測到環境未完整安裝或 Cloud Shell 系統層已重置，正在全自動重新部署（約 30 秒）..."
    "$DIR/install.sh"
    echo "✅ 系統環境部署完成！"
fi

# 2. 檢查目前是否已經在運行且網址有效
if tmux has-session -t desktop-gui 2>/dev/null && [ -f "$DIR/url.txt" ]; then
    "$DIR/status-desktop.sh"
    exit 0
fi

# 3. 啟動服務
echo "🔄 正在啟動 XFCE 桌面與安全連線通道..."
"$DIR/start-desktop.sh" >/dev/null 2>&1

# 4. 等待並取得連線網址
echo -n "⏳ 正在生成並驗證全球專屬通道"
for i in {1..25}; do
    URL=$(cat "$DIR/url.txt" 2>/dev/null)
    BACKUP_URL=$(cat "$DIR/url-backup.txt" 2>/dev/null)
    if [ -n "$URL" ] || [ -n "$BACKUP_URL" ]; then
        echo ""
        echo ""
        "$DIR/status-desktop.sh"
        exit 0
    fi
    echo -n "."
    sleep 1
done

echo ""
echo "⚠️ 連線通道建立中，請稍後幾秒再次輸入 'desktop' 查看網址。"
