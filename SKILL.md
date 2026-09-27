---
name: cloudshell-chrome-gui
description: >-
  Installs, configures, and manages a fully interactive Google Chrome GUI browser
  accessible via web browser using noVNC, Openbox, tint2, and Cloudflare Tunnel.
  Specifically optimized for headless Linux environments like Google Cloud Shell.
---

# Cloud Shell Chrome GUI Skill

This skill provides an automated workflow to deploy and maintain an operable, graphical Google Chrome browser on headless cloud Linux environments (such as Google Cloud Shell), viewable and interactive directly through any modern web browser without command-line dependencies.

## Key Technical Architecture

1. **Virtual Framebuffer (`Xvfb`)**: Creates a headless virtual display (`DISPLAY=:1`) at 1600x900 resolution with 24-bit color.
2. **Window Manager (`Openbox`)**: Lightweight X11 window manager handling window geometry and focus.
3. **Top Navigation Panel (`tint2`)**:
   - Fixed at the top (`panel_position = top center horizontal`) to avoid being obscured by browser viewports or taskbars.
   - Shows active and iconified (minimized) Chrome tasks.
   - Turns bright yellow when Chrome is minimized, allowing single-click restoration.
   - Includes a launcher button to easily focus or launch Chrome.
4. **VNC & HTML5 Streaming (`x11vnc` + `websockify` + `noVNC`)**:
   - Bridges the X11 display to a local RFB server on port 5900.
   - Exposes noVNC via WebSocket proxy on port 8080 with auto-connect and responsive viewport scaling.
5. **Secure Edge Tunnel (`cloudflared`)**:
   - **Critical Problem Solved**: Google Cloud Shell's built-in Web Preview (`*.cloudshell.dev`) blocks or drops WebSocket protocol upgrade handshakes (`Connection: Upgrade`).
   - Cloudflare Tunnel creates an encrypted outbound tunnel directly to Cloudflare edge nodes, providing native, uninterrupted WebSocket support without port forwarding or Google OAuth redirection loops.

---

## Directory Structure & Component Roles

```
~/chrome-web/
├── quick.sh          # All-in-one runner for Chrome mode (checks dependencies, restores, outputs URL)
├── start.sh          # Launches Chrome services inside detached tmux session 'chrome-gui'
├── stop.sh           # Gracefully terminates Chrome background services
├── status.sh         # Checks health and outputs current active tunnel URL for Chrome
├── run.sh            # Chrome supervisor executed inside tmux session
├── quick-desktop.sh  # All-in-one runner for XFCE desktop mode
├── start-desktop.sh  # Launches XFCE desktop inside detached tmux session 'desktop-gui'
├── stop-desktop.sh   # Gracefully terminates XFCE desktop services
├── status-desktop.sh # Checks health and outputs current active tunnel URL for XFCE
├── run-desktop.sh    # XFCE desktop supervisor executed inside tmux session
├── install.sh        # Dependency installer (Chrome, XFCE4, Xvfb, noVNC, websockify, tint2, fonts)
├── tint2rc           # Custom light-theme top panel configuration
└── cloudflared       # Static binary for Cloudflare Tunnel
```

---

## Standard Runbook Workflows

### 1. Initial Installation & Deployment

Run the installer followed by the start script:

```bash
~/chrome-web/install.sh
~/chrome-web/start.sh
```

Wait ~5 seconds, then check the generated URL:

```bash
~/chrome-web/status.sh
```

### 2. Fast Recovery (Ephemeral Reset Recovery)

Because Google Cloud Shell instances are ephemeral, system-level packages installed in root (`/`) are reset after extended idle periods, whereas `/home` persists.

Run `quick.sh` or the `chrome` command:

```bash
chrome
```

The script will:
- Detect missing system packages and reinstall them from cached packages in `/home/kconger867/chrome-web/` (~30 seconds).
- Re-launch the virtual display, window manager, top panel, and Chrome supervisor.
- Establish a fresh tunnel and output the active connection URL.

### 3. Window Minimization & Restoration

If Chrome is minimized:
- Click the **Chrome icon** on the top-left of the panel, or
- Click the **yellow task button** on the top bar.

To restore programmatically via terminal:

```bash
DISPLAY=:1 wmctrl -r "Google Chrome" -b remove,hidden
DISPLAY=:1 wmctrl -a "Google Chrome"
DISPLAY=:1 wmctrl -r "Google Chrome" -b add,maximized_vert,maximized_horz
```

---

## Troubleshooting Guide

| Issue | Root Cause | Solution |
| :--- | :--- | :--- |
| **"Connection Failed" / Loop on Web Preview** | Cloud Shell Web Preview drops WebSockets. | Use the Cloudflare Tunnel URL printed by `status.sh` or `quick.sh`. |
| **Old `trycloudflare.com` URL unreachable** | Quick Tunnels generate ephemeral URLs; old URLs expire on restart. | Re-run `status.sh` (or `chrome` / `desktop`) to get the latest active URL. |
| **Window minimized and vanished** | User clicked `-` (minimize) with no taskbar. | Click the yellow button on the top `tint2` panel or run `wmctrl -a "Google Chrome"`. |
| **Processes died on terminal exit** | Child processes received SIGHUP. | Always run services inside a detached `tmux` session (`start.sh`). |
| **Yellow `--no-sandbox` warning** | Chrome displays security banner when run unsandboxed. | Pass `--test-type` alongside `--no-sandbox` to suppress the banner. |
