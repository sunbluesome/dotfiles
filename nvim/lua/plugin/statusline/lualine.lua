-- lualine.lua
-- Config file for nvim-lualine/lualine.nvim
--
-- Used componensts:
-- SECTION_A:
--    - git branch
--    - diagnostics, shows erros and warnings (visible only if there are some)
--
-- SECTINO_B:
--     - current vim mode
--
-- SECTINO_C:
--     - filename
--
-- SECTION_X:
--     - git diff of current buffer
--     - current filetype of buffer
--
-- SECTION_Y:
--    - location of cursor in buffer
--
-- SECTION_Z:
--    - progress, how deep the location is in current bufferlocal lualine = require("lualine")

local diagnostics = {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    sections = { "error", "warn" },
    symbols = { error = "E", warn = "W" },
    colored = false,
    update_in_insert = false,
    always_visible = false,
}

local diff = {
    "diff",
    colored = true,
    symbols = { added = "+", modified = "~", removed = "-" },
}
 
local mode = {
    "mode",
}

local filetype = {
    "filetype",
    icons_enabled = true,
}

local branch = {
    "branch",
    icons_enabled = true,
    icon = "",
}

local location = {
    "location",
    padding = 0,
}

local filename = {
    "filename",
    path = 1
}

local progress = function()
    local current_line = vim.fn.line(".")
    local total_lines = vim.fn.line("$")
    local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
    local line_ratio = current_line / total_lines
    local index = math.ceil(line_ratio * #chars)
    return chars[index]
end

require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'solarized_dark',
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline" },
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        lualine_a = { branch, diagnostics },
        lualine_b = { mode },
        lualine_c = { filename },
        lualine_x = { diff, filetype, encofing },
        lualine_y = { location },
        lualine_z = { progress },
    },
    inactive_sections = {
        lualine_a = { branch, diagnostics },
        lualine_b = {},
        lualine_c = {},
        lualine_x = { diff, filetype },
        lualine_y = { location },
        lualine_z = { },
    },
    tabline = {},
    winbar = {},
}
