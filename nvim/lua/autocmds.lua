-- Create autocommand
local autocmd = vim.api.nvim_create_autocmd

-- Restore cursor location when file is opened
autocmd({ "BufReadPost" }, {
    pattern = { "*" },
    callback = function()
        vim.api.nvim_exec('silent! normal! g`"zv', false)
    end,
})
