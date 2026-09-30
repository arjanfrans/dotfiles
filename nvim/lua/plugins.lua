local gh = function(repo) return 'https://github.com/' .. repo end

vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind == 'update' then
            if not ev.data.active then
                vim.cmd.packadd('nvim-treesitter')
            end
            vim.cmd('TSUpdate')
        end
    end,
})

vim.g.VM_maps = {
    ['Find Under'] = '<C-m>',
    ['Find Subword Under'] = '<C-m>',
    ['Remove Region'] = '<C-b>',
    ['Skip Region'] = '<C-x>',
}

vim.g.delimitMate_expand_cr = 1
vim.g.delimitMate_expand_space = 1

vim.pack.add({
    gh('RRethy/base16-nvim'),
    { src = gh('nvim-treesitter/nvim-treesitter'), version = 'main' },
    gh('nvim-tree/nvim-web-devicons'),
    gh('nvim-lualine/lualine.nvim'),
    gh('nvim-tree/nvim-tree.lua'),
    gh('lewis6991/gitsigns.nvim'),
    gh('HiPhish/rainbow-delimiters.nvim'),
    gh('tpope/vim-fugitive'),
    gh('rhysd/conflict-marker.vim'),
    gh('mg979/vim-visual-multi'),
    gh('Raimondi/delimitMate'),
    gh('ton/vim-bufsurf'),
}, { confirm = false })

require('colorscheme')

local parsers = {
    'bash', 'css', 'dockerfile', 'html', 'javascript', 'json', 'lua', 'markdown',
    'markdown_inline', 'php', 'python', 'scss', 'sql', 'twig', 'typescript', 'tsx',
    'vim', 'vimdoc', 'xml', 'yaml',
}
local install = require('nvim-treesitter').install(parsers)
if #vim.api.nvim_list_uis() == 0 then
    install:wait(300000)
end

vim.api.nvim_create_autocmd('FileType', {
    callback = function(ev)
        if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})

require('lualine').setup({
    options = {
        theme = 'auto',
        globalstatus = true,
    },
})

require('nvim-tree').setup({
    filters = { git_ignored = false },
})

require('gitsigns').setup()
