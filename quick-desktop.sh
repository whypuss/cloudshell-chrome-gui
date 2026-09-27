#!/bin/bash

echo "=========================================="
echo "   🖥️ Linux XFCE 完整桌面一鍵啟動器"
echo "=========================================="

DIR="/home/kconger867/chrome-web"

# 1. 檢查是否需要重新安裝套件（若 Cloud Shell 閒置重啟還原了系統層）
if ! which xfce4-session >/dev/null 2>&1 || ! which Xvfb >/dev/null 2>&1 || ! which websockify >/dev/null 2>&1 || ! which google-chrome-stable >/dev/null 2>&1; then
    echo "📦 偵測到 Cloud Shell 系統層已重置，正在全自動部署桌面環境（約 30 秒）..."
    "$DIR/install.sh"
    echo "✅ 系統環境部署完成！"
fi

# 2. 檢查目前是否已經在運行
if tmux has-session -t desktop-gui 2>/dev/null && [ -f "$DIR/url.txt" ]; then
    CURRENT_URL=$(cat "$DIR/url.txt" 2>/dev/null)
    if [ -n "$CURRENT_URL" ]; then
        echo "⚡ XFCE 桌面目前已經在背景運行中！"
        echo ""
        echo "🌐 您的專屬連線網址："
        echo "👉 $CURRENT_URL"
        echo ""
        echo "💡 提醒：每次啟動通道皆會生成隨機新網址（舊網址會自動失效），請以此最新網址為準！"
        echo "=========================================="
        exit 0
    fi
fi

# 3. 啟動服務
echo "🔄 正在啟動 XFCE 虛擬桌面與安全連線通道..."
"$DIR/start-desktop.sh" >/dev/null 2>&1

# 4. 等待並取得連線網址
echo -n "⏳ 正在生成專屬連線網址"
for i in {1..20}; do
    URL=$(cat "$DIR/url.txt" 2>/dev/null)
    if [ -n "$URL" ]; then
        echo ""
        echo ""
        echo "🎉 啟動成功！請點擊下方專屬網址進入 Linux 完整桌面："
        echo ""
        echo "👉 $URL"
        echo ""
        echo "💡 提醒：每次啟動通道皆會生成隨機新網址（舊網址會自動失效），請以此最新網址為準！"
        echo "=========================================="
        exit 0
    fi
    echo -n "."
    sleep 1
done

echo ""
echo "⚠️ 連線通道建立中，請稍後幾秒再次輸入 'desktop' 查看網址。"
