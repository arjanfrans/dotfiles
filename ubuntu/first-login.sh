#!/usr/bin/env bash

DOTFILES="$HOME/.dotfiles"

until wget -q --spider --timeout=5 https://github.com; do
    echo "Waiting for an internet connection..."
    sleep 5
done

sudo rm -f /etc/xdg/autostart/dotfiles-setup.desktop /etc/skel/.config/gnome-initial-setup-done

if sudo apt-get update -y && sudo apt-get install -y git; then
    if [ ! -d "$DOTFILES/.git" ]; then
        git clone https://github.com/arjanfrans/dotfiles.git "$DOTFILES" \
            && git -C "$DOTFILES" remote set-url origin git@github.com:arjanfrans/dotfiles.git
    fi
    [ -d "$DOTFILES/.git" ] && cd "$DOTFILES" && ./setup.sh
fi

read -rp "Press enter to close"
