# See: https://github.com/Valloric/YouCompleteMe#ubuntu-linux-x64-super-quick-installation

# First install clang!!
sudo apt-get install cmake
sudo apt-get install python2.7-dev

sudo apt-get install libclang1
# dont think i need this: sudo pip2 install neovim

cd ~/.dotfiles/vim/vim/bundle/YouCompleteMe
 git submodule update --init --recursive
./install.sh --clang-completer

