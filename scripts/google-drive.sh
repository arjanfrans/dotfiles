#!/usr/bin/env bash
set -euo pipefail

# Mounts Google Drive at ~/GoogleDrive with rclone, on login via a systemd user service
REMOTE="gdrive"
MOUNT="$HOME/GoogleDrive"
SERVICE="$HOME/.config/systemd/user/rclone-gdrive.service"

sudo apt install -y rclone fuse3

if ! rclone listremotes | grep -qx "$REMOTE:"; then
    rclone config create "$REMOTE" drive scope=drive
fi

mkdir -p "$MOUNT" "$(dirname "$SERVICE")"

cat > "$SERVICE" <<EOF
[Unit]
Description=Google Drive (rclone)
After=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/rclone mount $REMOTE: $MOUNT --vfs-cache-mode full --vfs-cache-max-size 1G
ExecStop=/bin/fusermount3 -uz $MOUNT
Restart=on-failure

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now rclone-gdrive.service
