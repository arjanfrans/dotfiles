#!/bin/bash
script_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
for script in $script_dir/output/shell/base16*.sh; do
  script_name=$(basename $script .sh)
  theme=${script_name#*-}
  variation=${theme#*.}
  theme=${theme%.*}
  cat <<FUNC
base16_${theme}_${variation}()
{
  . $script
  ln -fs $script ~/.base16_theme 
  export BASE16_THEME=base16-${theme}
  export BASE16_VARIATION=$variation
  if type tmux_${variation} >/dev/null; then
    tmux_${variation}
  fi
  [ -f ~/.vimrc_background ] && rm ~/.vimrc_background
  cat <<vimrc_background > ~/.vimrc_background
set background=$variation
colorscheme base16-$theme
vimrc_background
}
FUNC
done;
[ -f  ~/.base16_theme ] && echo "~/.base16_theme"
#chmod +x ~/.base16_theme
