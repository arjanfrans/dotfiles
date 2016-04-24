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

gtheme() {
	source "$HOME/.dotfiles/colorschemes/base16-builder/output/gnome-terminal/$1.sh"
}

svimtabs () {
    if [ "$1" = "tabs" ]; then
        [ -f ~/.vimrc_tabs ] && rm ~/.vimrc_tabs
        echo -e "set set noexpandtab\n" > ~/.vimrc_tabs
        echo "Use hard tabs in vim:"
        cat ~/.vimrc_tabs
    elif [ "$1" = "spaces" ]; then
        [ -f ~/.vimrc_tabs ] && rm ~/.vimrc_tabs
        echo -e "set set expandtab\n" > ~/.vimrc_tabs
        echo "Use soft tabs in vim:"
        cat ~/.vimrc_tabs
    else
        echo "'tabs' or 'spaces'"
    fi
}

# Change the shell theme along with vim colorscheme
stheme() {
	if [ "$1" = "list" ]; then
		ls $HOME/.dotfiles/colorschemes/base16-builder/output/shell;
		return
	fi
	script="$HOME/.dotfiles/colorschemes/base16-builder/output/shell/$1.sh"
	script_name=$(basename $script .sh)
	theme=${script_name#*-}
	variation=${theme#*.}
	theme=${theme%.*}

	source $script
	ln -fs $script ~/.base16_theme
	export BASE16_THEME=base16-{$theme}
	export BASE16_VARIATION=$variation
	if type tmux_${variation} >/dev/null; then
		tmux_${variation}
	fi
	[ -f ~/.vimrc_background ] && rm ~/.vimrc_background
	echo -e "set background=$variation\ncolorscheme base16-$theme\n" > ~/.vimrc_background
}

ramdir() {
    real="$(readlink -m $1)"
    echo $real
    sudo mount -t tmpfs -o size=100m tmpfs $real
}

ramdisk() {
    sudo mkdir -p /mnt/ramdisk
    sudo mount -t tmpfs -o size=$1 tmpfs /mnt/ramdisk
}
