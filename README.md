# Cloud Shell Chrome GUI 🌐

> 在 Google Cloud Shell（或任何無螢幕雲端 Linux 伺服器）上輕鬆運行**可操作的 Google Chrome 圖形瀏覽器**。  
> 告別純命令列，直接在您的本地瀏覽器分頁中，用滑鼠點擊、開分頁、瀏覽網頁！

---

## 🌟 特色亮點

* **純滑鼠點擊操作**：完整的 Google Chrome 桌面版體驗，支援分頁、書籤、擴充功能與中文輸入。
* **突破 Cloud Shell 限制**：內建雙穿透通道（Cloudflare Tunnel + Pinggy 備用通道），完美解決 Cloud Shell Web Preview 阻擋 WebSocket 導致 noVNC 卡在「連線中...」的問題。
* **通道就緒預檢機制（零失敗率）**：啟動腳本會自動探測通道握手與全球 DNS 解析，保證印出網址時已 100% 可連線，徹底根除以往剛啟動點擊會出現的 `ERR_NAME_NOT_RESOLVED` 或連線超時問題。
* **頂部防呆導航列**：客製化頂部工具列（tint2），Chrome 縮小時按鈕自動變成**明亮金黃色**，隨時一鍵點擊還原視窗。
* **閒置重置自動還原**：Cloud Shell 重開機後，只需輸入 `chrome`，30 秒內自動補齊套件並印出新網址。
* **自動清理 SingletonLock**：解決 Chrome 在容器主機名變更後因設定檔鎖定而無法啟動的問題。
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
                       +-------------------------+-------------------------+
                       |                                                   |
                       v                                                   v
        +-----------------------------+                     +-----------------------------+
        | Cloudflare Tunnel (主通道)   |                     | Pinggy SSH Tunnel (備用通道) |
        +-----------------------------+                     +-----------------------------+
                       |                                                   |
                       +-------------------------+-------------------------+
                                                 | (HTTPS / WSS 直連)
                                                 v
                                  +-----------------------------+
                                  | 您的本地瀏覽器 (無需裝軟體) |
                                  +-----------------------------+
```

---

## 🚀 快速安裝與使用

### 1. 複製並安裝
在 Cloud Shell 終端機執行以下指令：

```bash
git clone https://github.com/whypuss/cloudshell-chrome-gui.git ~/chrome-web
cd ~/chrome-web
./install.sh
```
> 安裝腳本會全自動配置環境、下載 Chrome、下載通道二進位檔，並在系統註冊 `chrome` 與 `desktop` 全域捷徑指令。

### 2. 選擇啟動模式

本專案支援兩種運行模式：

* **模式 A：Chrome 專用模式（輕量推薦）**
  ```bash
  chrome
  # 或手動啟動：
  ./start.sh
  ./status.sh
  ```
  極簡 Openbox 視窗管理員 + 頂部防呆導航列，直開 Google Chrome，資源佔用極低。

* **模式 B：XFCE 完整桌面模式**
  ```bash
  desktop
  # 或手動啟動：
  ./start-desktop.sh
  ./status-desktop.sh
  ```
  包含桌面圖示（Chrome、檔案管理器、終端機）、工作列與完整應用選單。

### 3. 獲取連線網址
執行 `chrome`（或 `./status.sh`），終端機會在確認通道就緒後輸出連線網址：
```
==========================================
✅ Chrome Web GUI 目前正在運行中 (Running)
==========================================

🌐 主要連線網址（Cloudflare 隧道，無使用時限）：
👉 https://xxxx-xxxx.trycloudflare.com/vnc.html?autoconnect=true&resize=scale

⚡ 備用連線網址（Pinggy 零延遲通道，若主要通道無法打開請點此）：
👉 https://yyyy-yyyy.run.pinggy-free.link/vnc.html?autoconnect=true&resize=scale
```

**直接在您的本機瀏覽器點開上方任一網址，即可直通 Chrome 開始操作！**

---

## ⚡ 斷線後如何一鍵恢復？

在 Cloud Shell 中輸入單一指令：
* 恢復 Chrome 模式：`chrome`
* 恢復 XFCE 桌面模式：`desktop`

* **伺服器仍在運行時**：1 秒內立刻印出當前的最新連線網址。
* **伺服器閒置重置後**：自動重新部署環境（約 30 秒）並建立全新通道，自動印出可用網址。

---

## 📂 檔案目錄說明

| 檔案 | 說明 |
| :--- | :--- |
| `quick.sh` | Chrome 模式一鍵啟動與恢復器（綁定 `chrome` 指令） |
| `start.sh` | 在 tmux 背景中啟動 Chrome 專用環境 |
| `stop.sh` | 終止 Chrome 服務並釋放連接埠 |
| `status.sh` | 檢查 Chrome 運行狀態並輸出最新公開連線網址 |
| `run.sh` | Chrome 模式守護進程（Xvfb + Openbox + tint2 + x11vnc + websockify + 雙通道） |
| `quick-desktop.sh` | XFCE 完整桌面一鍵啟動與恢復器（綁定 `desktop` 指令） |
| `start-desktop.sh` | 在 tmux 背景中啟動 XFCE 完整桌面環境 |
| `stop-desktop.sh` | 終止 XFCE 桌面服務並釋放連接埠 |
| `status-desktop.sh` | 檢查 XFCE 桌面運行狀態並輸出最新公開連線網址 |
| `run-desktop.sh` | XFCE 桌面模式守護進程（Xvfb + XFCE4 Session + x11vnc + websockify + 雙通道） |
| `install.sh` | 自動安裝 Chrome、XFCE、Xvfb、noVNC、cloudflared、中文字型與全域捷徑 |
| `config/tint2rc` | 客製化頂部導航列設定檔（淺色系、防遮擋、縮小變黃提示） |
| `SKILL.md` | Antigravity / Gemini CLI Agent 專用 Skill 擴充定義檔 |

---

## 💡 常見問題 (FAQ)

### Q1：為什麼以前部署時點開網址打不開 Chrome？
> **原因**：Cloudflare 隨機生成的子域名在剛建立時需要 10~25 秒在全球邊緣節點與 DNS 生效。舊版腳本在通道尚未連通前就印出網址，導致使用者點擊時遇到 DNS 負快取（`ERR_NAME_NOT_RESOLVED` 或連線超時）。  
> **現已解決**：新版本加入了**連通性自動預先驗證機制**，並同時提供 **Pinggy 泛域名備用通道**（零 DNS 延遲），確保您點擊時 100% 能夠秒開。

### Q2：為什麼不能直接用 Cloud Shell 的「網頁預覽 (Web Preview)」？
> **原因**：Cloud Shell 的 Web Preview 底層是純 HTTP 反向代理，會阻擋或切斷 WebSocket (`wss://`) 協定。而遠端桌面必須依賴 WebSocket 傳輸即時畫面與滑鼠鍵盤訊號。本專案透過外網穿透通道解決此協定限制。

### Q3：不小心把 Chrome 縮小了怎麼辦？
> **解法**：在 Chrome 模式下看螢幕最上方的淺灰色工具列，縮小時按鈕會呈現**超醒目的金黃色**，用滑鼠點擊該按鈕即可立即還原視窗！在 XFCE 模式下則可點擊下方工作列恢復。

### Q4：如何讓連線網址永久固定不變？
> 目前預設使用的是免註冊的 Cloudflare 快速通道（每次重啟分配新隨機網址）。如果您有自己的 Cloudflare 帳號或網域，可在 Cloudflare Zero Trust 建立 Named Tunnel，將 Token 填入 `run.sh` / `run-desktop.sh`，即可享有永久固定的自訂網址（例如 `chrome.yourdomain.com`）。

---

## 📄 授權條款
MIT License. 歡迎自由修改、引用與分享！
