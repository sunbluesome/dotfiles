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
Map("n", "j", "gj")
Map("n", "k", "gk")
Map("n", "Y", "y$")

-- 行頭・行末への移動 (Shift+H/L)
Map("n", "H", "^")   -- 行頭（最初の非空白文字）
Map("n", "L", "$")   -- 行末
Map("v", "H", "^")   -- ビジュアルモードでも同様
Map("v", "L", "$")

-- switch window (Ctrl+hjkl)
Map("n", "<C-h>", "<C-w>h")
Map("n", "<C-j>", "<C-w>j")
Map("n", "<C-k>", "<C-w>k")
Map("n", "<C-l>", "<C-w>l")

-- Resize window (Shift+Ctrl+hjkl)
-- ウィンドウの位置に関係なく、常に直感的な方向にリサイズ
-- h: 分割線を左へ, l: 分割線を右へ, j: 分割線を下へ, k: 分割線を上へ

-- 現在のウィンドウが右端にあるかチェック
local function is_at_right_edge()
  local cur_win = vim.api.nvim_get_current_win()
  local cur_pos = vim.api.nvim_win_get_position(cur_win)
  local cur_width = vim.api.nvim_win_get_width(cur_win)
  local cur_right = cur_pos[2] + cur_width

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win ~= cur_win then
      local pos = vim.api.nvim_win_get_position(win)
      -- 他のウィンドウが右側にあるかチェック
      if pos[2] >= cur_right then
        return false
      end
    end
  end
  return true
end

-- 現在のウィンドウが下端にあるかチェック
local function is_at_bottom_edge()
  local cur_win = vim.api.nvim_get_current_win()
  local cur_pos = vim.api.nvim_win_get_position(cur_win)
  local cur_height = vim.api.nvim_win_get_height(cur_win)
  local cur_bottom = cur_pos[1] + cur_height

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win ~= cur_win then
      local pos = vim.api.nvim_win_get_position(win)
      -- 他のウィンドウが下側にあるかチェック
      if pos[1] >= cur_bottom then
        return false
      end
    end
  end
  return true
end

-- 分割線を左へ移動
Map("n", "<C-S-h>", function()
  if is_at_right_edge() then
    vim.cmd("vertical resize +2")
  else
    vim.cmd("vertical resize -2")
  end
end)

-- 分割線を右へ移動
Map("n", "<C-S-l>", function()
  if is_at_right_edge() then
    vim.cmd("vertical resize -2")
  else
    vim.cmd("vertical resize +2")
  end
end)

-- 分割線を上へ移動
Map("n", "<C-S-k>", function()
  if is_at_bottom_edge() then
    vim.cmd("resize +2")
  else
    vim.cmd("resize -2")
  end
end)

-- 分割線を下へ移動
Map("n", "<C-S-j>", function()
  if is_at_bottom_edge() then
    vim.cmd("resize -2")
  else
    vim.cmd("resize +2")
  end
end)

-- Navigate buffers (Alt+h/l)
Map("n", "<A-h>", ":bprevious<CR>")
Map("n", "<A-l>", ":bnext<CR>")

-- ウィンドウサイズ管理
Map("n", "<leader>w=", "<C-w>=", { noremap = true, silent = true, desc = "ウィンドウサイズを均等化" })
Map("n", "<leader>wm", "<C-w>_<C-w>|", { noremap = true, silent = true, desc = "ウィンドウを最大化" })

-- search
Map("n", "<ESC><ESC>", ":nohlsearch<CR><ESC>")

-- tabs
-- Map("n", "te", ":tabedit")
-- Map("n", "tn", ":tabnew<CR>")
Map("n", "th", "gT")
Map("n", "tl", "gt")

-- utils
-- Map("n", "<leader>h", "^")
-- Map("n", "<leader>l", "$")

-- maps in terminal mode -------------------------------
local term_opts = { silent = true }

-- ターミナルモードからノーマルモードに戻る
-- 注意: Claude Code 内では ESC は Claude Code に渡される
Map("t", "<C-[>", "<C-\\><C-n>", term_opts)         -- Ctrl+[ でノーマルモードへ

-- ウィンドウ移動 (Ctrl+hjkl)
-- 注意: Claude Code が Ctrl+h/j/k/l を使用している場合は動作しない
Map("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
Map("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
Map("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
Map("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

-- ウィンドウ移動の代替キー (Ctrl+w + hjkl)
-- Claude Code 内でも動作する可能性が高い
Map("t", "<C-w>h", "<C-\\><C-N><C-w>h", term_opts)
Map("t", "<C-w>j", "<C-\\><C-N><C-w>j", term_opts)
Map("t", "<C-w>k", "<C-\\><C-N><C-w>k", term_opts)
Map("t", "<C-w>l", "<C-\\><C-N><C-w>l", term_opts)
Map("t", "<C-w><C-w>", "<C-\\><C-N><C-w><C-w>", term_opts)  -- 次のウィンドウへ
