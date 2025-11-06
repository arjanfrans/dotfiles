#!/usr/bin/env bash
set -euo pipefail

echo "[*] Installing dependencies..."

# Ubuntu dependencies
sudo apt install -y playerctl imagemagick curl
snap install spotify

SCRIPTDIR="$HOME/.player-wallpaper"
mkdir -p "$SCRIPTDIR"

WALLSCRIPT="$SCRIPTDIR/player-wallpaper-daemon.sh"

cat > "$WALLSCRIPT" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

TMPDIR="$HOME/.player-wallpaper"
mkdir -p "$TMPDIR"
IMG="$TMPDIR/wallpaper.png"

last_track=""
preferred_player="spotify"

# Detect DBUS_SESSION_BUS_ADDRESS for current session (Wayland/X11)
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi

update_wallpaper() {
    # Check if preferred player is running
    if ! playerctl -l | grep -qx "$preferred_player"; then
        return
    fi

    # Fetch metadata for the preferred player
    track=$(playerctl -p "$preferred_player" metadata title 2>/dev/null || echo "")
    album=$(playerctl -p "$preferred_player" metadata album 2>/dev/null || echo "")
    artist=$(playerctl -p "$preferred_player" metadata artist 2>/dev/null || echo "")
    album_url=$(playerctl -p "$preferred_player" metadata mpris:artUrl 2>/dev/null || echo "")

    # Skip if nothing playing
    [[ -z "$track" ]] && return

    # Only update if track changed
    if [[ "$track" == "$last_track" ]]; then
        return
    fi
    last_track="$track"

    # Download or copy album art
    if [[ -n "$album_url" ]]; then
        if [[ "$album_url" == file://* ]]; then
            cp "${album_url#file://}" "$TMPDIR/album.png" || { echo "[!] Failed to copy album art"; return; }
        else
            curl -sL "$album_url" -o "$TMPDIR/album.png" || { echo "[!] Failed to download album art"; return; }
        fi
    else
        echo "[!] No album art for $track"
        return
    fi

    # Create wallpaper
    convert -size 1920x1080 xc:#1e1e1e "$TMPDIR/album.png" -resize 130% -gravity center -composite "$TMPDIR/temp.png"
    convert "$TMPDIR/temp.png" -gravity south \
        -background "#1e1e1e" -fill white -pointsize 34 \
        -splice 0x100 -annotate +0+300 "$artist - $track [$album]" "$IMG"

    # Set GNOME wallpaper
    gsettings set org.gnome.desktop.background picture-uri "file://$IMG"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$IMG"
    gsettings set org.gnome.desktop.background picture-options "centered"
    gsettings set org.gnome.desktop.screensaver picture-uri "file://$IMG"
    gsettings set org.gnome.desktop.screensaver picture-options "centered"

    echo "[*] Updated wallpaper: $artist - $track [$album]"
}

# Initial run
update_wallpaper

# Follow track changes reliably
while true; do
    while IFS= read -r _; do
        update_wallpaper
    done < <(playerctl -p "$preferred_player" metadata --follow 2>/dev/null)
    sleep 10
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

