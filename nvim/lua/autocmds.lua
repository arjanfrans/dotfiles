local autocmd = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup('dotfiles', { clear = true })

autocmd('BufReadPost', {
    group = group,
    desc = 'Go to the same line after reopening a file',
    callback = function()
        local line = vim.fn.line([['"]])
        if line > 0 and line <= vim.fn.line('$') then
            vim.cmd([[normal! g`"zvzz]])
        end
    end,
})

autocmd('WinEnter', { group = group, command = 'setlocal cursorline' })
autocmd('WinLeave', { group = group, command = 'setlocal nocursorline' })

autocmd('BufEnter', {
    group = group,
    callback = function()
        vim.opt.titlestring = ' ' .. vim.fn.expand('%:t')
    end,
})

autocmd('BufEnter', {
    group = group,
    nested = true,
    desc = 'Close nvim if the file tree is the only window left',
    callback = function()
        if vim.fn.winnr('$') == 1 and vim.bo.filetype == 'NvimTree' then
            vim.cmd.quit()
        end
    end,
})
