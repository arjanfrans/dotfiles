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
    if [ "$1" != "light" ] && [ "$1" != "dark" ]; then
        echo "Usage: theme_random <light|dark>"
        return 1
    fi

    local excluded_themes=(
        "greenscreen"
        "grayscale"
    )

    local themes_dir="$HOME/.dotfiles/colorschemes/base16-builder/output/shell"

    if [ ! -d "$themes_dir" ]; then
        echo "Themes directory not found: $themes_dir"
        return 1
    fi

    local all_themes=($(ls "$themes_dir" | grep "\.$1.sh" | sed -e 's/^base16-//' -e "s/\.$1.sh$//"))

    # Create a map of excluded themes for Bash-compatible filtering
    declare -A exclude_map
    for theme in "${excluded_themes[@]}"; do
        exclude_map["$theme"]=1
    done

    # Loop through all themes and build a new array without the excluded ones
    local themes=()
    for theme in "${all_themes[@]}"; do
        if [[ ! -v exclude_map["$theme"] ]]; then
            themes+=("$theme")
        fi
    done

    if [ ${#themes[@]} -eq 0 ]; then
        echo "No $1 themes found (or all were excluded) in: $themes_dir"
        return 1
    fi

    # Use Bash's 0-based array indexing
    local random_theme=${themes[ $(($RANDOM % ${#themes[@]})) ]}

    if [ -z "$random_theme" ]; then
        echo "Error: Random theme selection resulted in an empty name."
        return 1
    fi

    theme "$random_theme.$1"
}
