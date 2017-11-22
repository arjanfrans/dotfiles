sudo apt-get install python-software-properties -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim vim -y

pip3 install --user neovim jedi mistune psutil setproctitle
