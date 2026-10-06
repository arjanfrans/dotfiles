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
}

pinned_apps() {
    gsettings set org.gnome.shell favorite-apps "['google-chrome.desktop', 'brave-browser.desktop', 'org.gnome.Ptyxis.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Settings.desktop', 'screenshot.desktop', 'net.nokyan.Resources.desktop', 'spotify_spotify.desktop']"
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

terminal_font() {
    gsettings set org.gnome.Ptyxis use-system-font false
    gsettings set org.gnome.Ptyxis font-name "SauceCodePro Nerd Font Medium 11"
}

keyboard
natural_scrolling
no_auto_dimming
pinned_apps
dock
terminal_font
