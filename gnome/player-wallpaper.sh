#!/usr/bin/env bash
# Usage: player-wallpaper.sh [spanned|single]
#   spanned: current track on the leftmost monitor, previous tracks to its right
#   single:  current track on every monitor
set -euo pipefail

MODE="${1:-spanned}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/player-wallpaper"
mkdir -p "$CACHE_DIR"
BG="#1e1e1e"
HISTORY_SIZE=5

last_track=""
preferred_player="spotify"

# Detect DBUS_SESSION_BUS_ADDRESS for current session (Wayland/X11)
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi

# Prints "x y width height" per monitor, left to right
list_monitors() {
    /usr/bin/python3 - <<'PY' | sort -k1,1n -k2,2n
from gi.repository import Gio
proxy = Gio.DBusProxy.new_for_bus_sync(
    Gio.BusType.SESSION, Gio.DBusProxyFlags.NONE, None,
    "org.gnome.Mutter.DisplayConfig", "/org/gnome/Mutter/DisplayConfig",
    "org.gnome.Mutter.DisplayConfig", None,
)
_, monitors, logical_monitors, _ = proxy.call_sync("GetCurrentState", None, Gio.DBusCallFlags.NONE, -1, None).unpack()
current = {spec[0]: next(m for m in modes if m[6].get("is-current")) for spec, modes, _ in monitors}
for x, y, scale, transform, primary, specs, _ in logical_monitors:
    mode = current[specs[0][0]]
    w, h = (mode[2], mode[1]) if transform % 2 else (mode[1], mode[2])
    print(x, y, round(w / scale), round(h / scale))
PY
}

fetch_album_art() {
    local url=$1 out=$2
    if [[ "$url" == file://* ]]; then
        cp "${url#file://}" "$out"
    else
        curl -sfL "$url" -o "$out"
    fi
}

rotate_history() {
    for ((i = HISTORY_SIZE - 1; i > 0; i--)); do
        if [[ -f "$CACHE_DIR/album-$((i - 1)).png" ]]; then
            mv "$CACHE_DIR/album-$((i - 1)).png" "$CACHE_DIR/album-$i.png"
            mv "$CACHE_DIR/caption-$((i - 1)).txt" "$CACHE_DIR/caption-$i.txt"
        fi
    done
    mv "$CACHE_DIR/album-new.png" "$CACHE_DIR/album-0.png"
    printf '%s' "$1" > "$CACHE_DIR/caption-0.txt"
}

render_slide() {
    local slot=$1 width=$2 height=$3 out=$4
    if [[ ! -f "$CACHE_DIR/album-$slot.png" ]]; then
        convert -size "${width}x${height}" "xc:$BG" -depth 8 "$out"
        return
    fi
    convert -size "${width}x$((height - 100))" "xc:$BG" \
        \( "$CACHE_DIR/album-$slot.png" -resize 130% \) -gravity center -composite \
        -gravity south -background "$BG" -fill white -pointsize 34 \
        -splice 0x100 -annotate +0+150 "$(cat "$CACHE_DIR/caption-$slot.txt")" \
        -depth 8 "$out"
}

render_spanned() {
    local -a monitors=("$@")
    local min_x=999999 min_y=999999 max_x=0 max_y=0 x y w h
    for m in "${monitors[@]}"; do
        read -r x y w h <<< "$m"
        (( x < min_x )) && min_x=$x
        (( y < min_y )) && min_y=$y
        (( x + w > max_x )) && max_x=$((x + w))
        (( y + h > max_y )) && max_y=$((y + h))
    done

    local -a layers=()
    local slot=0
    for m in "${monitors[@]}"; do
        read -r x y w h <<< "$m"
        render_slide "$slot" "$w" "$h" "$CACHE_DIR/slide-$slot.miff"
        layers+=("$CACHE_DIR/slide-$slot.miff" -geometry "+$((x - min_x))+$((y - min_y))" -composite)
        slot=$((slot + 1))
    done

    convert -size "$((max_x - min_x))x$((max_y - min_y))" "xc:$BG" "${layers[@]}" -quality 92 "$IMG"
}

render_single() {
    local x y w h
    read -r x y w h <<< "$1"
    render_slide 0 "$w" "$h" "$CACHE_DIR/slide-0.miff"
    convert "$CACHE_DIR/slide-0.miff" -quality 92 "$IMG"
}

apply_wallpaper() {
    local options=$1
    gsettings set org.gnome.desktop.background picture-uri "file://$IMG"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$IMG"
    gsettings set org.gnome.desktop.background picture-options "$options"
}

apply_lockscreen() {
    convert "$CACHE_DIR/slide-0.miff" -quality 92 "$LOCKSCREEN"
    gsettings set org.gnome.desktop.screensaver picture-uri "file://$LOCKSCREEN"
    gsettings set org.gnome.desktop.screensaver picture-options "centered"
}

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

    if [[ -z "$album_url" ]]; then
        echo "[!] No album art for $track"
        return
    fi
    fetch_album_art "$album_url" "$CACHE_DIR/album-new.png" || { echo "[!] Failed to fetch album art"; return; }

    caption="$artist - $track [$album]"
    if [[ "$caption" != "$(cat "$CACHE_DIR/caption-0.txt" 2>/dev/null)" ]]; then
        rotate_history "$caption"
    fi
    refresh_wallpaper
    echo "[*] Updated wallpaper ($MODE): $artist - $track [$album]"
}

refresh_wallpaper() {
    [[ -f "$CACHE_DIR/album-0.png" ]] || return 0
    mapfile -t monitors < <(list_monitors)
    (( ${#monitors[@]} )) || { echo "[!] No monitors detected"; return; }

    (
        flock 9
        stamp=$(date +%s%N)
        IMG="$CACHE_DIR/wallpaper-$stamp.jpg"
        LOCKSCREEN="$CACHE_DIR/lockscreen-$stamp.jpg"
        if [[ "$MODE" == "single" ]]; then
            render_single "${monitors[0]}"
            apply_wallpaper "centered"
        else
            render_spanned "${monitors[@]}"
            apply_wallpaper "spanned"
        fi
        apply_lockscreen
        remove_stale_images "$stamp"
    ) 9> "$CACHE_DIR/render.lock"
}

# Every render gets a new file name so GNOME always reloads it
remove_stale_images() {
    find "$CACHE_DIR" -maxdepth 1 \( -name 'wallpaper*.jpg' -o -name 'lockscreen*.jpg' \) ! -name "*-$1.jpg" -delete
}

watch_monitor_changes() {
    gdbus monitor --session --dest org.gnome.Mutter.DisplayConfig --object-path /org/gnome/Mutter/DisplayConfig |
        while IFS= read -r line; do
            [[ "$line" == *MonitorsChanged* ]] || continue
            refresh_wallpaper
            echo "[*] Monitors changed, redrew wallpaper"
        done
}

# Initial run
update_wallpaper
watch_monitor_changes &
trap 'kill 0' EXIT

# Follow track changes reliably
while true; do
    while IFS= read -r _; do
        update_wallpaper
    done < <(playerctl -p "$preferred_player" metadata --follow 2>/dev/null)
    sleep 10
done
