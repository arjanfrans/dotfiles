" run set test lib
nnoremap <silent> ,rt :TestNearest<cr>
nnoremap <silent> ,rf :TestFile<cr>
nnoremap <silent> ,rl :TestLast<cr>
nnoremap <silent> ,rv :TestVisit<cr>
nnoremap <silent> ,rs :TestSuite<cr>

let test#strategy = "neoterm"
