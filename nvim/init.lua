require("core.base")
require("core.autocmds")
require("core.keymaps")
require("core.options")
require("plugin.packer")

local loader = require("core.config_loader")

loader:load_configs({
    "plugin.statusline.lualine",
    "plugin.colorscheme.nightfox",
    "plugin.completion.autopaires",
    "plugin.syntax.treesitter",
    "plugin.fuzzyfinder.telescope",
    "plugin.lsp",
    "plugin.completion.cmp",
    "plugin.linter.null-ls",
    "plugin.git.gitsigns",
    "plugin.git.diffview",
    "plugin.debugger",
    "plugin.syntax.ts-rainbow",
    "plugin.syntax.comment",
    "plugin.terminal.toggleterm",
    "plugin.bufferline.bufferline",
})

