-- Create autocommand
local autocmd = vim.api.nvim_create_autocmd

-- Restore cursor location when file is opened
autocmd({ "BufReadPost" }, {
    pattern = { "*" },
    callback = function()
        vim.cmd('silent! normal! g`"zv')
    end,
})

-- 外部でファイルが変更されたときに自動で再読み込み
vim.opt.autoread = true
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    pattern = { "*" },
    callback = function()
        if vim.fn.mode() ~= "c" then
            vim.cmd("checktime")
        end
    end,
})

-- ターミナルサイズ変更時にウィンドウサイズを均等化
autocmd({ "VimResized" }, {
    pattern = { "*" },
    callback = function()
        vim.cmd("wincmd =")
    end,
})
