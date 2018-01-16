sudo apt-get install neovim
sudo pip2 install neovim
sudo pip3 install neovim

curl -fLo ~/.dotfiles/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

mkdir -p nvim/.tmp
mkdir -p nvim/plugged

nvim +PlugInstall +qall
