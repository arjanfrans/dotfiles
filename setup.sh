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

# Switch caps lock and escape
dconf write "/org/gnome/desktop/input-sources/xkb-options" "['caps:swapescape']"

# Update submodules
run git submodule update --init --recursive

# Install
run sudo apt-get update -y
run sudo apt-get install -y curl git-lfs
run ./scripts/browsers.sh
run ./scripts/remove-apache.sh
run ./scripts/python.sh
run ./scripts/zsh.sh
run ./scripts/nvim.sh
run ./scripts/mssh.sh
run ./scripts/docker.sh
run ./scripts/spotify.sh
run ./scripts/claude.sh

# Copy config files
cp "$DOTFILES/git/gitconfig" ~/.gitconfig
sudo cp "$DOTFILES/sysctl/99-sysctl_idea.conf" /etc/sysctl.d/99-sysctl_idea.conf
sudo cp "$DOTFILES/sysctl/99-sysctl_elasticsearch.conf" /etc/sysctl.d/99-sysctl_elasticsearch.conf
run sudo sysctl --system

# Symlinks
link "$DOTFILES/fonts" ~/.local/share/fonts
link "$DOTFILES/xorg/xinitrc" ~/.xinitrc
link "$DOTFILES/zsh/zshrc" ~/.zshrc
link "$DOTFILES/nvim" ~/.config/nvim
link "$DOTFILES/idea/ideavimrc" ~/.ideavimrc
link "$DOTFILES/private/CLAUDE.md" ~/.claude/CLAUDE.md
link "$DOTFILES/colorschemes/base16-builder/output/vim" "$DOTFILES/nvim/colors"

rm -f ~/.base16_theme
: > ~/.vimrc_background
run fc-cache -f

# Neovim plugins (needs ~/.config/nvim to be linked)
run nvim --headless +PlugInstall +qall

# This changes the default shell for the *current* user
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(which zsh)" ]; then
    run chsh -s "$(which zsh)"
fi

if [ ${#FAILED[@]} -gt 0 ]; then
    echo
    echo "The following steps failed:"
    printf '  - %s\n' "${FAILED[@]}"
    exit 1
fi

echo
echo "Done. Log out and back in for the shell and docker group changes to take effect."
