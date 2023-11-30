require("core.base")
require("core.autocmds")
require("core.keymaps")
require("core.options")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


if vim.g.vscode then
    require('lazy').setup({
        spec = {
            -- common
            { import = "plugins.comment" },
            { import = "plugins.hop" },
            -- For vscode
        }
    })
else
    require('lazy').setup({
        spec = {
            -- common
            { import = "plugins.comment" },
            { import = "plugins.gitsigns" },
            { import = "plugins.hop" },
            { import = "plugins.bufferline" },
            -- For neovim
            { import = "plugins.dap" },
            { import = "plugins.completion" },
            { import = "plugins.color-scheme" },
            { import = "plugins.diffview" },
            { import = "plugins.lazygit" },
            { import = "plugins.lualine" },
            { import = "plugins.null_ls" },
            { import = "plugins.nvim-ts-rainbow" },
            { import = "plugins.telescope-file-browser" },
            { import = "plugins.telescope" },
            { import = "plugins.treesitter" },
            { import = "plugins.trouble" },
        }
    })
end

