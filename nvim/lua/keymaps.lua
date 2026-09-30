local map = vim.keymap.set

map('n', '<F12>', '<Cmd>set paste!<CR>')

map('n', 'n', "'Nn'[v:searchforward].'zz'", { expr = true })
map('n', 'N', "'nN'[v:searchforward].'zz'", { expr = true })
map('n', 'G', 'Gzz')
map('n', '}', '}zz')
map('n', '{', '{zz')

map('', '<C-h>', '<C-w>h')
map('', '<C-j>', '<C-w>j')
map('', '<C-k>', '<C-w>k')
map('', '<C-l>', '<C-w>l')

map('t', '<Esc>', '<C-\\><C-n>')

map('n', '<leader>/', '<Cmd>nohlsearch<CR>', { silent = true })

map('', '0', '^')

map('n', '<C-i>', '<Cmd>BufSurfBack<CR>', { silent = true })
map('n', '<C-o>', '<Cmd>BufSurfForward<CR>', { silent = true })

map('', '<C-n>', '<Cmd>NvimTreeToggle<CR>')

vim.api.nvim_create_user_command('FormatJSON', '%!python3 -m json.tool', {})
