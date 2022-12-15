-- Maps.lua
-- File for non-plugin remappings and Map options.
--
-- Modes:
--   norma_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c"

-- Function for mapping keybinds.
-- Default options:
-- 		remap = true
--  	silent = true
--
-- @param mode string in which mode the cmd will execute
-- @param keys string key sequence/combination
-- @param cmd string|function command which will be executed
-- @param options table|nil optional options
function Map(mode, keys, cmd, options)
    options = options or { noremap = true, silent = true }
    vim.keymap.set(mode, keys, cmd, options)
end

-- Remap space as leader key
Map("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- maps in insert mode ---------------------------------
Map("i", "jk", "<ESC>")

-- maps in normal mode ---------------------------------
Map("n", "L", "<C-u>setlocal relativenumber!<CR>")
Map("n", "j", "gj")
Map("n", "k", "gk")
Map("n", "Y", "y$")

-- Navigate buffers
Map("n", "<A-l>", ":bnext<CR>")
Map("n", "<A-h>", ":bprevious<CR>")

-- switch window
Map("n", "<C-h>", "<C-w>h")
Map("n", "<C-j>", "<C-w>j")
Map("n", "<C-k>", "<C-w>k")
Map("n", "<C-l>", "<C-w>l")

-- Resize with arrows
Map("n", "<C-Up>", ":resize -2<CR>")
Map("n", "<C-Down>", ":resize +2<CR>")
Map("n", "<C-Left>", ":vertical resize +2<CR>")
Map("n", "<C-Right>", ":vertical resize -2<CR>")

-- search
Map("n", "<ESC><ESC>", ":nohlsearch<CR><ESC>")

-- tabs
Map("n", "te", ":tabedit")
Map("n", "tn", ":tabnew<CR>")
Map("n", "th", "gT")
Map("n", "tl", "gt")

-- utils
Map("n", "<Space>h", "^")
Map("n", "<Space>l", "$")

-- maps in terminal mode -------------------------------
local term_opts = { silent = true }
Map("t", "<ESC>", "<C-\\><C-n>")
Map("t", "jk", "<C-\\><C-n>")
Map("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
Map("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
Map("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
Map("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)
