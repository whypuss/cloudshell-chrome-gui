#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "   🚀 Chrome Web GUI 一鍵快速啟動器"
echo "=========================================="

# 1. 檢查是否需要重新安裝套件（若 Cloud Shell 閒置重啟還原了系統層）
if ! which google-chrome-stable >/dev/null 2>&1 || ! which Xvfb >/dev/null 2>&1 || ! which tint2 >/dev/null 2>&1 || ! which websockify >/dev/null 2>&1 || [ ! -x "$DIR/cloudflared" ]; then
    echo "📦 偵測到環境未完整安裝或 Cloud Shell 系統層已重置，正在全自動重新部署（約 30 秒）..."
    "$DIR/install.sh"
    echo "✅ 系統環境部署完成！"
fi

# 確保頂部工作列設定存在
mkdir -p ~/.config/tint2
if [ ! -f ~/.config/tint2/tint2rc ]; then
    if [ -f "$DIR/config/tint2rc" ]; then
        cp "$DIR/config/tint2rc" ~/.config/tint2/tint2rc
    elif [ -f "$DIR/tint2rc" ]; then
        cp "$DIR/tint2rc" ~/.config/tint2/tint2rc
    fi
fi

# 2. 檢查目前是否已經在運行且網址有效
if tmux has-session -t chrome-gui 2>/dev/null && [ -f "$DIR/url.txt" ]; then
    "$DIR/status.sh"
    exit 0
fi

# 3. 啟動服務
echo "🔄 正在啟動 Chrome 虛擬桌面與安全連線通道..."
"$DIR/start.sh" >/dev/null 2>&1

# 4. 等待並取得連線網址（含連線能力預先檢測）
echo -n "⏳ 正在生成並驗證全球專屬通道"
for i in {1..25}; do
    URL=$(cat "$DIR/url.txt" 2>/dev/null)
    BACKUP_URL=$(cat "$DIR/url-backup.txt" 2>/dev/null)
    if [ -n "$URL" ] || [ -n "$BACKUP_URL" ]; then
        echo ""
        echo ""
        "$DIR/status.sh"
        exit 0
    fi
    echo -n "."
    sleep 1
done

echo ""
echo "⚠️ 連線通道建立中，請稍後幾秒再次輸入 'chrome' 查看網址。"
