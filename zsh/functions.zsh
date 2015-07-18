dotinstall() {
    file="$HOME/.dotfiles/scripts/$1.sh"
    echo "$file"
    if [ -f "$file" ]; then
        chmod +x "$file"
        sh "$file"
    else
        echo "$file not found!"
    fi
}

settheme() {
	source "$HOME/.dotfiles/colorschemes/base16-builder/output/gnome-terminal/$1.sh"
}

ramdisk() {
    sudo mkdir -p /mnt/ramdisk
    sudo mount -t tmpfs -o size=$1 tmpfs /mnt/ramdisk
}
