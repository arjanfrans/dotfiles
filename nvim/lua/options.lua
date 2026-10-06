local tmp = vim.fn.stdpath('config') .. '/.tmp'

vim.g.loaded_matchparen = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.completeopt:remove('preview')

vim.opt.wrap = false
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftround = true

vim.opt.showmode = false

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.cursorline = true
vim.opt.synmaxcol = 200
vim.opt.startofline = false
vim.opt.scrolloff = 10
vim.opt.signcolumn = 'yes'
vim.opt.list = true
vim.opt.listchars = { tab = '· ', nbsp = '+' }

vim.opt.undofile = true
vim.opt.undodir = tmp
vim.opt.undolevels = 200
vim.opt.history = 200

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.backupdir = tmp
vim.opt.directory = tmp

vim.opt.shada:prepend('%')

vim.opt.wildignore:append({ '*.so', '*.swp', '*.zip', '*.exe' })

vim.opt.title = true
