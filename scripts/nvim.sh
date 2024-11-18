sudo apt-get install neovim -y
sudo apt-get install python3-neovim -y

curl -fLo ~/.dotfiles/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

mkdir -p nvim/.tmp
mkdir -p nvim/plugged

nvim +PlugInstall +qall
