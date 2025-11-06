#!/bin/bash

# Switch caps lock and escape
dconf write "/org/gnome/desktop/input-sources/xkb-options" "['caps:swapescape']"

# Update submodules
git submodule update --init --recursive

# Install
sudo apt-get update -y
sudo apt install -y curl
./scripts/browsers.sh
./scripts/remove-apache.sh
./scripts/python.sh
./scripts/zsh.sh
./scripts/nvim.sh
./scripts/mssh.sh
./scripts/docker.sh
./scripts/spotify.sh

# Cleanup
rm -f ~/.gitconfig
rm -rf ~/.local/share/fonts
rm -f ~/.xinitrc
rm -f ~/.zshrc
rm -rf ~/.config/nvim
rm -f ~/.vimrc_background
rm -f ~/.base16_theme
rm -rf ~/.dotfiles/nvim/colors
rm -rf ~/.ideavimrc
rm -rf ~/.player-wallpaper
sudo rm -rf /etc/sysctl.d/99-sysctl_idea.conf
sudo rm -rf /etc/sysctl.d/99-sysctl_elasticsearch.conf

# Copy config files
cp ~/.dotfiles/git/gitconfig ~/.gitconfig
sudo cp ~/.dotfiles/sysctl/99-sysctl_idea.conf /etc/sysctl.d/99-sysctl_idea.conf
sudo cp ~/.dotfiles/sysctl/99-sysctl_elasticsearch.conf /etc/sysctl.d/99-sysctl_elasticsearch.conf

# Symlinks
ln -sf ~/.dotfiles/fonts ~/.local/share/fonts
ln -sf ~/.dotfiles/xorg/xinitrc ~/.xinitrc
ln -sf ~/.dotfiles/zsh/zshrc ~/.zshrc
ln -sf ~/.dotfiles/nvim ~/.config/nvim
ln -sf ~/.dotfiles/idea/ideavimrc ~/.ideavimrc
ln -sf ~/.dotfiles/colorschemes/base16-builder/output/vim ~/.dotfiles/nvim/colors

touch ~/.vimrc_background

# This changes the default shell for the *current* user
chsh -s $(which zsh)

