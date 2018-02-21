# Install
sudo apt-get update -y
./scripts/zsh.sh 
./scripts/nvim.sh 

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

# Symlinks
cp ~/.dotfiles/git/gitconfig ~/.gitconfig
ln -sf ~/.dotfiles/fonts ~/.local/share/fonts
ln -sf ~/.dotfiles/xorg/xinitrc ~/.xinitrc
ln -sf ~/.dotfiles/zsh/zshrc ~/.zshrc
ln -sf ~/.dotfiles/nvim ~/.config/nvim
ln -sf ~/.dotfiles/idea/ideavimrc ~/.ideavimrc
ln -sf ~/.dotfiles/colorschemes/base16-builder/output/vim ~/.dotfiles/nvim/colors

touch ~/.vimrc_background
