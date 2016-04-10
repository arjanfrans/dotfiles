
call plug#begin('~/.config/nvim/plugged')

" Make sure you use single quotes
Plug 'Shougo/deoplete.nvim'

" Javascript completion
Plug 'carlitux/deoplete-ternjs'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" git integration
Plug 'airblade/vim-gitgutter'

" syntax checker
"Plug 'scrooloose/syntastic'

" Add plugins to &runtimepath
call plug#end()

source ~/.config/nvim/config/themes.vim
source ~/.config/nvim/config/syntax.vim
"source ~/.config/nvim/config/autocomplete.vim

" disable preview window
set completeopt-=preview
