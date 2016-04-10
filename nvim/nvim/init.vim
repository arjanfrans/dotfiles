set nocompatible
set t_Co=256

call plug#begin('~/.config/nvim/plugged')

" Make sure you use single quotes
Plug 'Shougo/deoplete.nvim'

" Javascript completion
Plug 'carlitux/deoplete-ternjs'

" Allow normal tab when autocomplete key is tab
Plug 'ervandew/supertab'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" git integration
Plug 'airblade/vim-gitgutter'

" File search
Plug 'ctrlpvim/ctrlp.vim'

" Faster matcher for ctrlp
Plug 'FelikZ/ctrlp-py-matcher'

" Comments
Plug 'tomtom/tcomment_vim'

" Toggle quickfix and location list
Plug 'Valloric/ListToggle'

" Multiple cursors
Plug 'terryma/vim-multiple-cursors'

" Auto complete quotes
Plug 'Raimondi/delimitMate'

" Nerdtree
Plug 'scrooloose/nerdtree'

" syntax checker
Plug 'benekastah/neomake'

" Add plugins to &runtimepath
call plug#end()

source ~/.config/nvim/config/themes.vim
source ~/.config/nvim/config/syntax.vim
source ~/.config/nvim/config/autocomplete.vim
source ~/.config/nvim/config/ctrlp.vim
source ~/.config/nvim/config/nerdtree.vim
source ~/.config/nvim/config/multicursor.vim

" disable preview window
set completeopt-=preview

" Line highlight that moves with the cursor
set cursorline

set nowrap
set number

" Hide current mode in the default status bar. Use airline instead
set noshowmode

set encoding=utf-8

" Keep unsaved buffers open
set hidden

" Enable mouse
set mouse=a

" Highlight search
set hlsearch

" Search incremental
set incsearch

" Use softtabs
set expandtab

set tabstop=4
set shiftwidth=4
set softtabstop=4

set ignorecase
set smartcase

set novisualbell
set noerrorbells

" Always show status line
set laststatus=2

" Leader key
let mapleader = ","

" Window navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Move out of terminal with esc
tnoremap <Esc> <C-\><C-n>

"Presistent undo
if has("persistent_undo")
	set undodir='~/.config/nvim/'
	set undofile
	set undolevels=200
endif

" List toggles
let g:lt_location_list_toggle_map = '<leader>1'
let g:lt_quickfix_list_toggle_map = '<leader>2'

set history=200

set noswapfile
set nobackup
" Swap files out of the project root
set backupdir=~/.config/nvim/backup
set directory=~/.config/nvim/swap

" Go to the same line after reopening a file
augroup line_return
	au!
	au BufReadPost *
				\ if line("'\"") > 0 && line("'\"") <= line("$") |
				\     execute 'normal! g`"zvzz' |
				\ endif
augroup END

" Remember info about open buffers on close
set viminfo^=%

" Clear highlighted search
nmap <silent> <leader>/ :nohlsearch<CR>

set wildignore+=*.so,*.swp,*.zip     " MacOSX/Linux
set wildignore+=*.swp,*.zip,*.exe  " Windows

" Remap VIM 0 to first non-blank character
map 0 ^
