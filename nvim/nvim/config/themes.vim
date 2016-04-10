" Pretty colors
if filereadable(expand("~/.vimrc_background"))
	let base16colorspace=256
	source ~/.vimrc_background
endif

" Airline bar
let g:airline_theme = 'base16'
let g:airline_powerline_fonts = 1
