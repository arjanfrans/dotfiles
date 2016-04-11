" Use deoplete.
let g:deoplete#enable_at_startup = 1

" Let <Tab> also do completion
inoremap <silent><expr> <Tab>
\ pumvisible() ? "\<C-n>" :
\ deoplete#mappings#manual_complete()

" Super tab (cycle forward) (default is <c-p), which is backward)
let g:SuperTabDefaultCompletionType = "<c-n>"
