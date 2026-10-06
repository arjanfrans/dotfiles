#!/bin/bash
set -uo pipefail

DOTFILES="$HOME/.dotfiles"
cd "$DOTFILES"

FAILED=()

run() {
    echo "==> $*"
    "$@" || FAILED+=("$*")
}

link() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    rm -rf "$dest"
    ln -s "$src" "$dest"
}

# GitHub CLI + login first, so the private repo can be cloned
run ./scripts/gh.sh
run ./scripts/glab.sh

# Private submodule (needs an SSH key registered with GitHub)
echo "==> git submodule update --init --recursive"
if git submodule update --init --recursive; then
    link "$DOTFILES/private/CLAUDE.md" ~/.claude/CLAUDE.md
    link "$DOTFILES/private/settings.json" ~/.claude/settings.json
else
    echo "Could not clone the private repo. Add your SSH key to GitHub, then run:"
    echo "  git -C $DOTFILES submodule update --init --recursive"
    echo "  ln -sfn $DOTFILES/private/CLAUDE.md ~/.claude/CLAUDE.md"
    echo "  ln -sfn $DOTFILES/private/settings.json ~/.claude/settings.json"
    FAILED+=("git submodule update --init --recursive")
fi

# GNOME settings (before installs, which append to the pinned apps)
run ./gnome/settings.sh

# Install
run sudo apt-get update -y
run sudo apt-get install -y curl git-lfs
run ./scripts/browsers.sh
run ./scripts/chrome-app.sh TEAMS https://teams.cloud.microsoft/
[ -x ./private/slack.sh ] && run ./private/slack.sh
[ -x ./private/timetracking.sh ] && run ./private/timetracking.sh
run ./scripts/phpstorm.sh
run ./scripts/remove-apache.sh
run ./scripts/python.sh
run ./scripts/zsh.sh
run ./scripts/nvim.sh
run ./scripts/mssh.sh
run ./scripts/docker.sh
run ./scripts/spotify.sh
run ./scripts/claude.sh

# Copy config files
GIT_NAME="$(git config --global user.name)"
GIT_EMAIL="$(git config --global user.email)"
if [ -e ~/.gitconfig ]; then
    read -rp "Overwrite ~/.gitconfig? [y/N]: " input
    [[ "$input" =~ ^[Yy] ]] && cp "$DOTFILES/git/gitconfig" ~/.gitconfig
else
    cp "$DOTFILES/git/gitconfig" ~/.gitconfig
fi
sudo cp "$DOTFILES/sysctl/99-sysctl_idea.conf" /etc/sysctl.d/99-sysctl_idea.conf
sudo cp "$DOTFILES/sysctl/99-sysctl_elasticsearch.conf" /etc/sysctl.d/99-sysctl_elasticsearch.conf
run sudo sysctl --system

# Symlinks
link "$DOTFILES/fonts" ~/.local/share/fonts
link "$DOTFILES/xorg/xinitrc" ~/.xinitrc
link "$DOTFILES/applications/screenshot.desktop" ~/.local/share/applications/screenshot.desktop
link "$DOTFILES/zsh/zshrc" ~/.zshrc
link "$DOTFILES/nvim" ~/.config/nvim
link "$DOTFILES/idea/ideavimrc" ~/.ideavimrc
for dir in ~/.config/JetBrains/PhpStorm*/; do
    [ -d "$dir" ] && link "$DOTFILES/idea/keymaps/Dotfiles.xml" "$dir/keymaps/Dotfiles.xml"
done

rm -f ~/.base16_theme
run fc-cache -f

# Terminal palettes (Ptyxis)
run ./scripts/ptyxis-palettes.sh

# Neovim plugins and treesitter parsers (needs ~/.config/nvim to be linked)
run nvim --headless +qall

# This changes the default shell for the *current* user
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(which zsh)" ]; then
    run sudo chsh -s "$(which zsh)" "$USER"
fi

# Git identity
read -rp "Git name [$GIT_NAME]: " input && GIT_NAME="${input:-$GIT_NAME}"
read -rp "Git email [$GIT_EMAIL]: " input && GIT_EMAIL="${input:-$GIT_EMAIL}"
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

if [ ${#FAILED[@]} -gt 0 ]; then
    echo
    echo "The following steps failed:"
    printf '  - %s\n' "${FAILED[@]}"
    exit 1
fi

echo
echo "Done. Log out and back in for the shell and docker group changes to take effect."
read -rp "Log out now? [Y/n]: " input
if [[ ! "$input" =~ ^[Nn] ]]; then
    gnome-session-quit --logout --no-prompt
fi
