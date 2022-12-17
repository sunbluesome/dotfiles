-- init.lua
--
-- Main configuration file for nvim-dap plugin, used
-- to launch debugger.

require("dap")


vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "", linehl = "", numhl = "" })

Map('n', '<F5>', ':DapContinue<CR>')
Map('n', '<F10>', ':DapStepOver<CR>')
Map('n', '<F11>', ':DapStepInto<CR>')
Map('n', '<F12>', ':DapStepOut<CR>')
Map('n', '<leader>b', ':DapToggleBreakpoint<CR>')
Map('n', '<leader>dr', ':lua require("dap").repl.open()<CR>')


require("plugin.debugger.dap-events")
require("plugin.debugger.nvim-dap-python")
require("plugin.debugger.nvim-dap-ui")
require("plugin.debugger.virtual-text")
require("plugin.debugger.telescope-ext")

