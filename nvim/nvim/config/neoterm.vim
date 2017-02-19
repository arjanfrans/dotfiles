let g:neoterm_size = 80
let g:neoterm_position = 'horizontal'
let g:neoterm_automap_keys = ',tt'

nnoremap <silent> <f10> :TREPLSendFile<cr>
nnoremap <silent> <f9> :TREPLSend<cr>
vnoremap <silent> <f9> :TREPLSend<cr>

" Useful maps
" hide/close terminal
nnoremap <silent> ,th :call neoterm#toggle()<cr>
" clear terminal
nnoremap <silent> ,tl :call neoterm#clear()<cr>
" kills the current job (send a <c-c>)
nnoremap <silent> ,tc :call neoterm#kill()<cr>


" Split vertical
let g:neoterm_position = 'vertical'
" Open in split on new terminal
let g:neoterm_split_on_tnew = 1

" Rails commands
command! Troutes :T rake routes
command! -nargs=+ Troute :T rake routes | grep <args>
command! Tmigrate :T rake db:migrate

" Git commands
command! -nargs=+ Tg :T git <args>

let g:neoterm_close_when_tests_succeed = 1
let g:neoterm_raise_when_tests_fail = 1
let g:neoterm_keep_term_open = 1
