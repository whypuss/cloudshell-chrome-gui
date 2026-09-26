# Cloud Shell Chrome GUI 🌐

> 在 Google Cloud Shell（或任何無螢幕雲端 Linux 伺服器）上輕鬆運行**可操作的 Google Chrome 圖形瀏覽器**。  
> 告別純命令列，直接在您的本地瀏覽器分頁中，用滑鼠點擊、開分頁、瀏覽網頁！

---

## 🌟 特色亮點

* **純滑鼠點擊操作**：完整的 Google Chrome 桌面版體驗，支援分頁、書籤、擴充功能與中文輸入。
* **突破 Cloud Shell 限制**：內建 Cloudflare 安全穿透通道，完美解決 Cloud Shell Web Preview 阻擋 WebSocket 導致 noVNC 無法連線的問題。
* **頂部防呆導航列**：客製化頂部工具列（tint2），Chrome 縮小時按鈕自動變成**明亮金黃色**，隨時一鍵點擊還原視窗。
* **閒置重置自動還原**：Cloud Shell 重開機後，只需輸入 `chrome`，30 秒內自動補齊套件並印出新網址。
* **永久保留個人資料**：瀏覽紀錄、書籤、Cookies 存放在 `/home` 永久硬碟，重新啟動後資料不丟失。

---

## 🏗️ 系統架構

```
+-------------------------------------------------------------------+
|                        Google Cloud Shell                         |
|                                                                   |
|   +-----------------------+      +----------------------------+   |
|   |   Google Chrome (GUI) | <--> |   Xvfb (:1 虛擬顯示器)      |   |
|   +-----------------------+      +----------------------------+   |
|                                                |                  |
|   +-----------------------+                    v                  |
|   |  tint2 頂部導航列     |        +-----------------------+      |
|   +-----------------------+        |   x11vnc (5900 RFB)   |      |
|                                    +-----------------------+      |
|                                                |                  |
|                                                v                  |
|                                    +-----------------------+      |
|                                    | websockify (8080)     |      |
|                                    | + noVNC HTML5 介面    |      |
|                                    +-----------------------+      |
|                                                |                  |
+------------------------------------------------|------------------+
                                                 |
                                                 v
                                  +-----------------------------+
                                  | Cloudflare Tunnel (QUIC)    |
                                  +-----------------------------+
                                                 |
                                                 v (HTTPS / WSS)
                                  +-----------------------------+
                                  | 您的本地瀏覽器 (無需裝軟體) |
                                  +-----------------------------+
```

---

## 🚀 快速安裝與使用

### 1. 複製並安裝
在 Cloud Shell 終端機執行以下指令：

```bash
git clone https://github.com/YOUR_USERNAME/cloudshell-chrome-gui.git ~/chrome-web
cd ~/chrome-web
./install.sh
./start.sh
```

### 2. 獲取連線網址
執行：
```bash
./status.sh
```
終端機將會顯示一組專屬的 Cloudflare 安全連線網址，例如：
`https://xxxx-xxxx.trycloudflare.com`

**直接在您的瀏覽器點開此網址，即可開始用滑鼠操作 Chrome！**

---

## ⚡ 斷線後如何一鍵恢復？

在 Cloud Shell 中輸入單一指令：
```bash
chrome
```
* **伺服器仍在運行時**：1 秒內立刻印出當前的連線網址。
* **伺服器閒置重置後**：自動重新部署環境（約 30 秒）並建立全新通道，自動印出可用網址。

---

## 📂 檔案目錄說明

| 檔案 | 說明 |
| :--- | :--- |
| `quick.sh` | 智慧一鍵啟動與恢復器（綁定 `chrome` 指令） |
| `install.sh` | 自動安裝 Chrome、Xvfb、noVNC、中文字型與工具列 |
| `start.sh` | 在獨立的 tmux 背景工作階段中啟動所有服務 |
| `stop.sh` | 安全終止所有背景服務並釋放連接埠 |
| `status.sh` | 檢查目前運行狀態並輸出公開連線網址 |
| `run.sh` | 守護進程，負責維持虛擬螢幕、工具列與 Chrome 運行 |
| `config/tint2rc` | 客製化頂部導航列設定檔（淺色系、防遮擋、縮小變黃提示） |
| `SKILL.md` | Antigravity / Gemini CLI Agent 專用 Skill 擴充定義檔 |

---

## 💡 常見問題 (FAQ)

### Q1：為什麼不能直接用 Cloud Shell 的「網頁預覽 (Web Preview)」？
> **原因**：Cloud Shell 的 Web Preview 底層是純 HTTP 反向代理，會阻擋或切斷 WebSocket (`wss://`) 協定。而遠端桌面必須依賴 WebSocket 傳輸即時畫面與滑鼠鍵盤訊號。本專案透過 Cloudflare Tunnel 完美解決此協定限制。

### Q2：不小心把 Chrome 縮小了怎麼辦？
> **解法**：看螢幕最上方的淺灰色工具列，縮小時按鈕會呈現**超醒目的金黃色**，用滑鼠點擊該按鈕即可立即還原視窗！

### Q3：如何讓連線網址永久固定不變？
> 目前預設使用的是免註冊的 Cloudflare 快速通道（每次重啟分配新隨機網址）。如果您有自己的 Cloudflare 帳號或網域，可在 Cloudflare Zero Trust 建立 Named Tunnel，將 Token 填入 `run.sh`，即可享有永久固定的自訂網址（例如 `chrome.yourdomain.com`）。

---

## 📄 授權條款
MIT License. 歡迎自由修改、引用與分享！
