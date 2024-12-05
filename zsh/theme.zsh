# Change the shell theme along with vim colorscheme
theme() {
	if [ "$1" = "list" ]; then
		ls $HOME/.dotfiles/colorschemes/base16-builder/output/shell;
		return
	fi

	script="$HOME/.dotfiles/colorschemes/base16-builder/output/shell/base16-$1.sh"
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

theme_random() {
    # Check if a valid argument is passed (light or dark)
    if [ "$1" != "light" ] && [ "$1" != "dark" ]; then
        echo "Usage: theme_random <light|dark>"
        return 1
    fi

    # Directory containing the theme scripts
    themes_dir="$HOME/.dotfiles/colorschemes/base16-builder/output/shell"

    # Check if the themes directory exists
    if [ ! -d "$themes_dir" ]; then
        echo "Themes directory not found: $themes_dir"
        return 1
    fi

    # Get the list of themes for the specified variation (light or dark)
    themes=($(ls "$themes_dir" | grep "\.$1.sh" | sed -e 's/^base16-//' -e "s/\.$1.sh$//"))

    # Check if there are any themes
    if [ ${#themes[@]} -eq 0 ]; then
        echo "No $1 themes found in: $themes_dir"
        return 1
    fi

    # Select a random theme from the list
    random_theme=${themes[$RANDOM % ${#themes[@]}]}

    # Ensure the theme name is not empty
    if [ -z "$random_theme" ]; then
        echo "Error: Random theme selection resulted in an empty name."
        return 1
    fi

    # Apply the random theme
    theme "$random_theme.$1"
}


