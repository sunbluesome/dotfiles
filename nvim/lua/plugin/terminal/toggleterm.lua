local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({
    cmd = "lazygit",
    direction = "float",
    hidden = true,
    float_opts = {
        border = "double",
    },
    close_on_exit = true,
    -- function to run on opening the terminal
    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(
            term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true}
        )
    end,
})

local shell = Terminal:new({
    direction = "float",
    hidden = true,
    float_opts = {
        border = "double",
    },
    close_on_exit = true,
    -- function to run on opening the terminal
    on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(
            term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true}
        )
        vim.api.nvim_buf_set_keymap(
            term.bufnr, "n", "<ESC>", "<C-\\><C-n>", {noremap = true, silent = true}
        )
    end,
})

function _lazygit_toggle()
    lazygit:toggle()
end

function _shell_toggle()
    shell:toggle()
end

vim.api.nvim_set_keymap(
    "n",
    "<leader>lg",
    "<cmd>lua _lazygit_toggle()<CR>",
    { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
    "n",
    "<leader>te",
    "<cmd>lua _shell_toggle()<CR>",
    { noremap = true, silent = true }
)

