let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }

let g:ctrlp_working_path_mode = 'ra'

let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'

" Ignore files in .gitignore
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_mruf_relative = 1

nnoremap <c-f> :CtrlPFunky<Cr>
