#!/usr/bin/env bash
set -euo pipefail

# Ptyxis ignores background colors set by escape codes, so each base16 theme
# becomes a Ptyxis palette that the `theme` shell function switches to.

THEMES_DIR="$HOME/.dotfiles/colorschemes/base16-builder/output/shell"
PALETTES_DIR="$HOME/.local/share/org.gnome.Ptyxis/palettes"

hex() {
    echo "#${1//\//}"
}

palette_section() {
    local file="$1" key value i
    declare -A colors

    while IFS='=' read -r key value; do
        value="${value%% #*}"
        value="${value//\"/}"
        [[ "$value" == \$* ]] && value="${colors[${value#\$}]}"
        colors[$key]="$value"
    done < <(grep -E '^color[_a-z0-9]+=' "$file")

    echo "Foreground=$(hex "${colors[color_foreground]}")"
    echo "Background=$(hex "${colors[color_background]}")"
    for i in $(seq 0 15); do
        printf 'Color%d=%s\n' "$i" "$(hex "${colors[$(printf 'color%02d' "$i")]}")"
    done
}

mkdir -p "$PALETTES_DIR"

for dark in "$THEMES_DIR"/base16-*.dark.sh; do
    theme="$(basename "$dark" .dark.sh)"
    light="$THEMES_DIR/$theme.light.sh"
    name="$(sed -n 's/^# \(.*\) - Shell color setup script$/\1/p' "$dark")"

    {
        echo "[Palette]"
        echo "Name=$name"
        echo
        echo "[Dark]"
        palette_section "$dark"
        echo
        echo "[Light]"
        palette_section "$light"
    } > "$PALETTES_DIR/$theme.palette"
done
