#!/usr/bin/env bash
set -euo pipefail

keyboard() {
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us+altgr-intl'), ('xkb', 'de')]"
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:swapescape']"

    gsettings set org.gnome.desktop.peripherals.keyboard repeat true
    gsettings set org.gnome.desktop.peripherals.keyboard delay 150
    gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 7
}

natural_scrolling() {
    gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
    gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true
}

no_auto_dimming() {
    gsettings set org.gnome.settings-daemon.plugins.power idle-dim false
    gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false
    gsettings set org.gnome.desktop.session idle-delay 900
}

pinned_apps() {
    gsettings set org.gnome.shell favorite-apps "['google-chrome.desktop', 'brave-browser.desktop', 'org.gnome.Ptyxis.desktop', 'jetbrains-phpstorm.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Settings.desktop', 'screenshot.desktop', 'net.nokyan.Resources.desktop', 'spotify_spotify.desktop', 'chrome-app-fsnc.desktop', 'chrome-app-teams.desktop', 'fusonic-timetracking.desktop']"
}

dock() {
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
    gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false
    gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor true
    gsettings set org.gnome.shell.extensions.dash-to-dock require-pressure-to-show false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-delay 0.0
}

enable_extension() {
    local uuid=$1 enabled
    enabled=$(gsettings get org.gnome.shell enabled-extensions)
    if [[ "$enabled" != *"$uuid"* ]]; then
        gsettings set org.gnome.shell enabled-extensions "${enabled%]*}, '${uuid}']"
    fi
}

top_bar_on_all_monitors() {
    local uuid="multi-monitors-bar@frederykabryan"
    local shell_version zip
    shell_version=$(gnome-shell --version | grep -oP '\d+' | head -1)
    zip=$(mktemp --suffix=.zip)
    curl -fsSL -o "$zip" "https://extensions.gnome.org/download-extension/${uuid}.shell-extension.zip?shell_version=${shell_version}"
    gnome-extensions install --force "$zip"
    rm "$zip"

    enable_extension "$uuid"
}

cap_resolution() {
    mkdir -p ~/.config/systemd/user
    ln -sfn "$(realpath "$(dirname "$0")")/cap-resolution.service" ~/.config/systemd/user/cap-resolution.service
    systemctl --user daemon-reload
    systemctl --user enable --now cap-resolution.service
}

install_local_extension() {
    local uuid=$1
    mkdir -p ~/.local/share/gnome-shell/extensions
    ln -sfn "$(realpath "$(dirname "$0")")/extensions/$uuid" ~/.local/share/gnome-shell/extensions/$uuid
    enable_extension "$uuid"
}

lockscreen_unblur() {
    install_local_extension "lockscreen-unblur@dotfiles"
}

lockscreen_prank() {
    install_local_extension "lockscreen-prank@dotfiles"
}

terminal_font() {
    gsettings set org.gnome.Ptyxis use-system-font false
    gsettings set org.gnome.Ptyxis font-name "SauceCodePro Nerd Font Medium 11"
}

keyboard
natural_scrolling
no_auto_dimming
pinned_apps
dock
top_bar_on_all_monitors
cap_resolution
lockscreen_unblur
lockscreen_prank
terminal_font
