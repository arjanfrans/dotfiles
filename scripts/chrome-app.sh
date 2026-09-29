#!/usr/bin/env bash
set -euo pipefail

# Usage: chrome-app.sh <name> <url> [icon-url]
NAME="$1"
URL="$2"
HOST="$(echo "$URL" | sed -E 's#^https?://([^/]+).*#\1#')"
ICON_URL="${3:-https://www.google.com/s2/favicons?domain=$HOST&sz=128}"

ID="$(echo "$NAME" | tr '[:upper:] ' '[:lower:]-')"
APP_PATH="$(echo "$URL" | sed -E 's#^https?://[^/]+##')"
WM_CLASS="chrome-${HOST}_${APP_PATH//\//_}-Default"

ICON="$HOME/.local/share/icons/chrome-app-$ID.png"
DESKTOP="$HOME/.local/share/applications/chrome-app-$ID.desktop"

mkdir -p "$(dirname "$ICON")" "$(dirname "$DESKTOP")"
curl -fsSL "$ICON_URL" -o "$ICON"

cat > "$DESKTOP" <<EOF
[Desktop Entry]
Type=Application
Name=$NAME
Exec=google-chrome --app=$URL
Icon=$ICON
StartupWMClass=$WM_CLASS
Terminal=false
EOF

"$(dirname "$0")/pin-app.sh" "chrome-app-$ID.desktop"
