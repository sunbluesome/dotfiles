local keymap = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}


--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- Modes
--   normal_mode = 'n',
--   insert_mode = 'i',
--   visual_mode = 'v',
--   visual_block_mode = 'x',
--   term_mode = 't',
--   command_mode = 'c',


-- keymaps in insert mode
keymap("i", "jk", "<ESC>", opts)

-- keymaps in normal mode
keymap("n", "L", "<C-u>setlocal relativenumber!<CR>", opts)
keymap("n", "j", "gj", opts)
keymap("n", "k", "gk", opts)
keymap("n", "Y", "y$", opts)
-- window
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)
-- search
keymap("n", "<ESC><ESC>", ":nohlsearch<CR><ESC>", opts)
-- tabs
keymap("n", "te", ":tabedit", opts)
keymap("n", "tn", ":tabnew<CR>", opts)
keymap("n", "th", "gT", opts)
keymap("n", "tl", "gt", opts)
-- utils
keymap("n", "<Space>h", "^", opts)
keymap("n", "<Space>l", "$", opts)

-- keymap in terminal
keymap("t", "<ESC>", "<C-\\><C-n>", opts)
keymap("t", "jk", "<C-\\><C-n>", opts)

-- telescope
local suceeded, builtin = pcall(require, 'telescope.builtin')
if suceeded then
    vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
    vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
end

-- telescope-file-browser
local suceeded, telescope = pcall(require, 'telescope')
if suceeded then
    -- telescope file browser
    local function telescope_buffer_dir()
        return vim.fn.expand("%:p:h")
    end
    vim.keymap.set("n", "<leader>fe", function()  -- file explorer as fe
        telescope.extensions.file_browser.file_browser({
            path = "%:p:h",
            cwd = telescope_buffer_dir(),
            grouped = true,
            hidden = true,
            previewer = false,
            initial_mode = "normal",
            layout_config = { height = 40 },
        })
    end)
end
