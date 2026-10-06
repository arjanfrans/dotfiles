#!/usr/bin/env bash
set -euo pipefail

echo "[*] Installing dependencies..."

# Ubuntu dependencies
sudo apt install -y playerctl imagemagick curl
sudo snap install spotify

# Wallpaper mode: "spanned" (rotating history across monitors) or "single" (current track on every monitor)
WALLPAPER_MODE="${1:-spanned}"
WALLSCRIPT="$(realpath "$(dirname "$0")/../gnome/player-wallpaper.sh")"

# === Create systemd user service to auto-start the daemon ===
SYSTEMD_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_DIR"

SERVICE_FILE="$SYSTEMD_DIR/player-wallpaper.service"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Player Wallpaper Daemon
After=graphical.target

[Service]
ExecStart=$WALLSCRIPT $WALLPAPER_MODE
Restart=always
Environment=DISPLAY=:0
Environment=XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR

[Install]
WantedBy=default.target
EOF

echo "[*] Installed systemd user service at $SERVICE_FILE"

# === Enable and start the service at login ===
systemctl --user daemon-reload
systemctl --user enable player-wallpaper.service
systemctl --user restart player-wallpaper.service

echo "[*] Player wallpaper daemon is now running in the background and will auto-start at login."

echo
echo "Check its status with:"
echo "  systemctl --user status player-wallpaper.service"

