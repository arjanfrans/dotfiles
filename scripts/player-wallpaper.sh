#!/usr/bin/env bash
set -euo pipefail

echo "[*] Installing dependencies..."

# Ubuntu dependencies
sudo apt update
sudo apt install -y playerctl imagemagick curl

# === Create scripts directory ===
SCRIPTDIR="$HOME/.player-wallpaper"
mkdir -p "$SCRIPTDIR"

# === Write the Player wallpaper daemon script ===
WALLSCRIPT="$SCRIPTDIR/player-wallpaper-daemon.sh"

cat > "$WALLSCRIPT" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

TMPDIR="$HOME/.player-wallpaper"
mkdir -p "$TMPDIR"
IMG="$TMPDIR/wallpaper.png"

# Last track to avoid unnecessary updates
last_track=""

update_wallpaper() {
    track=$(playerctl metadata title 2>/dev/null || echo "")
    album=$(playerctl metadata album 2>/dev/null || echo "")
    artist=$(playerctl metadata artist 2>/dev/null || echo "")
    album_url=$(playerctl metadata mpris:artUrl 2>/dev/null || echo "")

    # Only update if track actually changed
    if [[ "$track" == "$last_track" ]]; then
        return
    fi
    last_track="$track"

    # Download album art or fallback blank
    if [[ -n "$album_url" ]]; then
        curl -s "$album_url" -o "$TMPDIR/album.png"
    else
        return
    fi

    # Create wallpaper: solid background, album art centered
    convert -size 1920x1080 xc:#1e1e1e "$TMPDIR/album.png" -resize 120% -gravity center -composite "$TMPDIR/temp.png"

    # Annotate track + artist below the image
    convert "$TMPDIR/temp.png" -gravity south \
        -background "#1e1e1e" -fill white -pointsize 34 \
        -splice 0x100 -annotate +0+260 "$artist - $track [$album]" "$IMG"

    # Set wallpaper
    gsettings set org.gnome.desktop.background picture-uri "file://$IMG"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$IMG"
    gsettings set org.gnome.desktop.background picture-options "centered"
    gsettings set org.gnome.desktop.screensaver picture-uri "file://$IMG"
    gsettings set org.gnome.desktop.screensaver picture-options "centered"
}

# Initial run
update_wallpaper

# Update on track changes
playerctl metadata --follow | while read -r _; do
    update_wallpaper
done
EOF

chmod +x "$WALLSCRIPT"
echo "[*] Installed Player wallpaper daemon at $WALLSCRIPT"

# === Create systemd user service to auto-start the daemon ===
SYSTEMD_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_DIR"

SERVICE_FILE="$SYSTEMD_DIR/player-wallpaper.service"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Player Wallpaper Daemon
After=graphical.target

[Service]
ExecStart=$WALLSCRIPT
Restart=always
Environment=DISPLAY=:0
Environment=XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR

[Install]
WantedBy=default.target
EOF

echo "[*] Installed systemd user service at $SERVICE_FILE"

# === Enable and start the service at login ===
systemctl --user daemon-reload
systemctl --user enable --now player-wallpaper.service

echo "[*] Player wallpaper daemon is now running in the background and will auto-start at login."

echo
echo "Check its status with:"
echo "  systemctl --user status player-wallpaper.service"

