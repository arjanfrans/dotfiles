" Check syntax on save
autocmd! BufWritePost * Neomake

let g:neomake_javascript_enabled_makers = ['eslint']

let g:neomake_cpp_enabled_makers = []

let g:neomake_warning_sign = {
  \ 'text': 'W',
  \ 'texthl': 'WarningMsg',
  \ }
let g:neomake_error_sign = {
  \ 'text': 'E',
  \ 'texthl': 'ErrorMsg',
  \ }

let g:neomake_open_list = 2
let g:neomake_list_height = 5
