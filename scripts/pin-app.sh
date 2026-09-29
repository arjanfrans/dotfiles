#!/usr/bin/env bash
set -euo pipefail

# Usage: pin-app.sh <desktop-file>
APP="$1"

FAVORITES="$(gsettings get org.gnome.shell favorite-apps)"
if [[ "$FAVORITES" != *"'$APP'"* ]]; then
    if [[ "$FAVORITES" == "@as []" || "$FAVORITES" == "[]" ]]; then
        FAVORITES="['$APP']"
    else
        FAVORITES="${FAVORITES%]}, '$APP']"
    fi
    gsettings set org.gnome.shell favorite-apps "$FAVORITES"
fi
