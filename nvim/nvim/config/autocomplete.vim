inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
set shortmess+=c

" Supertab top to bottom instead of bottom to top 
let g:SuperTabDefaultCompletionType = "<c-n>"
