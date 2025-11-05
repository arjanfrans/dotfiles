# Load a specific theme
theme() {
    if [ "$1" = "list" ]; then
        ls "$HOME/.dotfiles/colorschemes/base16-builder/output/shell"
        return
    fi

    if [ "$1" = "current" ]; then
        if [ -f ~/.base16_theme ]; then
            basename "$(readlink -f ~/.base16_theme)" .sh
        else
            echo "No theme currently set."
        fi
        return
    fi

    local script="$HOME/.dotfiles/colorschemes/base16-builder/output/shell/base16-$1.sh"
    if [ ! -f "$script" ]; then
        echo "Theme not found: $1"
        return 1
    fi

    local script_name=$(basename "$script" .sh)
    local theme=${script_name#*-}
    local variation=${theme#*.}
    theme=${theme%.*}

    source "$script"
    ln -fs "$script" ~/.base16_theme
    export BASE16_THEME="base16-$theme"
    export BASE16_VARIATION="$variation"

    if type "tmux_$variation" >/dev/null 2>&1; then
        "tmux_$variation"
    fi

    [ -f ~/.vimrc_background ] && rm ~/.vimrc_background
    echo -e "set background=$variation\ncolorscheme base16-$theme\n" > ~/.vimrc_background
}

# Load a random theme
theme_random() {
    if [ "$1" != "light" ] && [ "$1" != "dark" ]; then
        echo "Usage: theme_random <light|dark>"
        return 1
    fi

    local excluded_themes=("greenscreen" "grayscale")
    local themes_dir="$HOME/.dotfiles/colorschemes/base16-builder/output/shell"

    if [ ! -d "$themes_dir" ]; then
        echo "Themes directory not found: $themes_dir"
        return 1
    fi

    # Get all themes of the correct variation
    local all_themes=($(ls "$themes_dir" | grep "\.$1.sh$" | sed -e 's/^base16-//' -e "s/\.$1.sh$//"))

    # Filter out excluded themes
    local themes=()
    for theme in "${all_themes[@]}"; do
        local skip=0
        for ex in "${excluded_themes[@]}"; do
            [[ "$theme" == "$ex" ]] && skip=1 && break
        done
        [[ $skip -eq 0 ]] && themes+=("$theme")
    done

    if [ ${#themes[@]} -eq 0 ]; then
        echo "No $1 themes found (or all were excluded) in: $themes_dir"
        return 1
    fi

    # Pick a random theme
    local random_theme
    while [ -z "$random_theme" ]; do
        random_theme=${themes[RANDOM % ${#themes[@]}]}
    done

    theme "$random_theme.$1"
}

