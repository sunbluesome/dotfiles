vim.cmd("autocmd!")
vim.scriptencoding = "utf-8"
-- terminal
vim.cmd("command! -nargs=* T split | wincmd j | resize 20 | terminal <args>")
vim.cmd("autocmd TermOpen * startinsert")

