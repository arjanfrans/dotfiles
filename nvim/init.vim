call plug#begin('~/.config/nvim/plugged')

" Theme
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Nerdtree
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'rhysd/conflict-marker.vim'

" Comments
Plug 'tomtom/tcomment_vim'

" Multiple cursors
Plug 'terryma/vim-multiple-cursors'

" Auto complete quotes
Plug 'Raimondi/delimitMate'


Plug 'ton/vim-bufsurf'

" Rainbow parenthesis
Plug 'luochen1990/rainbow'

" Add plugins to &runtimepath
call plug#end()

source ~/.config/nvim/config/themes.vim
source ~/.config/nvim/config/nerdtree.vim
source ~/.config/nvim/config/multicursor.vim

" hide matching parenthesis
let g:loaded_matchparen=1

" disable preview window
set completeopt-=preview

set nowrap
set number
set relativenumber

filetype plugin indent on  " Load plugins according to detected filetype.
syntax on                  " Enable syntax highlighting.

set expandtab              " Use spaces instead of tabs.

set autoindent             " Indent according to previous line.
set tabstop=4
set softtabstop=4          " Tab key indents by 4 spaces.
set shiftwidth=4           " >> indents by 4 spaces.
set shiftround             " >> indents to next multiple of 'shiftwidth'.

set hidden                 " Switch between buffers without having to save first.<Paste>
set laststatus=2           " Always show statusline."
set display=lastline       " Show as much as possible of the last line."

set noshowmode             " Hide current mode in the default status bar. Use airline instead

set incsearch              " Highlight while searching with / or ?.
set hlsearch               " Keep matches highlighted.
set wrapscan               " Searches wrap around end-of-file.
set ignorecase             " Case insensitive search
set smartcase              " Case sensitive when uc present

set splitbelow             " Open new windows below the current window.
set splitright             " Open new windows right of the current window.
set cursorline             " Find the current line quickly.
set synmaxcol=200          " Only highlight the first 200 columns.

set nostartofline " When off the cursor is kept in the same column (if possible)

set encoding=utf-8

set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)

" Enable mouse
set mouse=a

set novisualbell
set noerrorbells

let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle

" The direction of n and N depends on whether / or ? was used for searching forward or backward respectively.
" If you want n to always search forward and N backward, use this:
nnoremap <expr> n  'Nn'[v:searchforward]
nnoremap <expr> N  'nN'[v:searchforward]

" Leader key
let mapleader = ","

" Window navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Format json
com! FormatJSON %!python -m json.tool

" Move out of terminal with esc
tnoremap <Esc> <C-\><C-n>

"Presistent undo
if has("persistent_undo")
	set undodir=~/.config/nvim/.tmp
	set undofile
	set undolevels=200
endif

set history=200

set noswapfile
set nobackup

" Swap files out of the project root
set backupdir=~/.config/nvim/.tmp
set directory=~/.config/nvim/.tmp

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

" Cycle through buffers
nmap <silent> <C-i> :BufSurfBack<CR>
nmap <silent> <C-o> :BufSurfForward<CR>

" Auto center on G
nmap G Gzz
nmap n nzz
nmap N Nzz
nmap } }zz
nmap { {zz}

" Cursorline only in current window
autocmd WinEnter    * set cursorline
autocmd WinLeave    * set nocursorline

" Minimum lines to keep above and below cursor     
set scrolloff=10 

let g:delimitMate_expand_cr = 1
let g:delimitMate_expand_space = 1

" Set terminal title to filename
autocmd BufEnter * let &titlestring = ' ' . expand("%:t")             
set title
