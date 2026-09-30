local function terminal_theme_file()
    local file = vim.uv.fs_realpath(vim.fn.expand('~/.base16_theme'))
    if file then
        return file, file:match('%.(%a+)%.sh$')
    end
end

local function read_base16_colors(file)
    local colors = {}
    for line in io.lines(file) do
        local r, g, b, base = line:match('^color%w+="(%x%x)/(%x%x)/(%x%x)" # Base (%x%x)')
        if base then
            colors['base' .. base] = '#' .. r .. g .. b
        end
    end
    return colors
end

local function invert_grays(colors)
    for i = 0, 3 do
        local dark, light = 'base0' .. i, 'base0' .. (7 - i)
        colors[dark], colors[light] = colors[light], colors[dark]
    end
    return colors
end

local function use_terminal_background(background)
    for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
        if not hl.link and hl.bg == background then
            hl.bg = nil
            vim.api.nvim_set_hl(0, name, hl)
        end
    end
end

local function dim_whitespace(color)
    vim.api.nvim_set_hl(0, 'Whitespace', { fg = color })
end

local file, variation = terminal_theme_file()
if file then
    local colors = read_base16_colors(file)
    if variation == 'light' then
        vim.o.background = 'light'
        colors = invert_grays(colors)
    else
        vim.o.background = 'dark'
    end
    require('base16-colorscheme').setup(colors)
else
    vim.cmd.colorscheme('base16-tomorrow-night')
end

local colors = require('base16-colorscheme').colors
use_terminal_background(tonumber(colors.base00:sub(2), 16))
dim_whitespace(colors.base02)
