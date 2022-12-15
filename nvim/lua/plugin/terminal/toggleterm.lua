-- toggleterm.lua
-- Config file for akinsho/toggleterm.nvim
--
-- KEYMAPS:
-- CTRL + \ => opens new floating terminal, which can be toggled
-- CTRL + g => opens new floating terminal with lazygit
-- CTRL + p => opens new floating terminal with python shell
-- CTRL + t => opens new floating terminal with htop
-- CTRL + F10 => toggles _CODE_RUNNER terminal, @see yabs.lua
--
-- Also there is a toggle function for terminal with NCDU
--
-- _CODE_RUNNER is function for spawning hidden terminals
-- with build/run commands.

local toggleterm = require("toggleterm")

local size = 80
local direction = "float"

toggleterm.setup({
	size = size,
	open_mapping = [[<c-\>]],
	hide_numbers = true,
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = 2,
	start_in_insert = true,
	insert_mappings = true,
	persist_size = true,
	direction = direction,
	close_on_exit = true,
	shell = vim.o.shell,
	float_opts = {
		border = "curved",
		winblend = 0,
		highlights = {
			border = "Normal",
			background = "Normal",
		},
	},
})

function _G.set_terminal_keymaps()
	local opts = { noremap = true }
	vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
	-- these navigate to different window, without closing the terminal
	-- NOTE: doesnt make sense for float, works in horizonatl and vertical
	vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

local terminal = require("toggleterm.terminal").Terminal

local lazygit = terminal:new({ cmd = "lazygit", hidden = true })
function _LAZYGIT_TOGGLE()
	lazygit:toggle()
end

Map("n", "<c-g>", function() _LAZYGIT_TOGGLE() end)

local ncdu = terminal:new({ cmd = "ncdu", hidden = true })
function _NCDU_TOGGLE()
	ncdu:toggle()
end

local htop = terminal:new({ cmd = "htop", hidden = true })
function _HTOP_TOGGLE()
	htop:toggle()
end

Map("n", "<c-t>", function() _HTOP_TOGGLE() end)

local python = terminal:new({ cmd = "python3", hidden = true })
function _PYTHON_TOGGLE()
	python:toggle()
end

Map("n", "<c-p>", function() _PYTHON_TOGGLE() end)

local terminal_runner = nil
function _CODE_RUNNER(command)
	local terminal_id = 10

	if terminal_runner == nil then
		terminal_runner = terminal:new({
			count = terminal_id, -- something like an ID
			direction = direction,
			hidden = true,

			on_open = function(term)
				vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
			end,
		})
	end

	terminal_runner:open(size, direction)
	terminal_runner:send(command)
end

function _TOGGLE_CODE_RUNNER()
	if not (terminal_runner == nil) then
		terminal_runner:toggle()
	end
end

Map("n", "<F34>", function() _TOGGLE_CODE_RUNNER() end) -- CTRL + F10 == F34