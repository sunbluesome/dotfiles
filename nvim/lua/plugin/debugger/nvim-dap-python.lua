-- nvim-dap-python.lua
--
-- Config file for setting up nvim-dap debugger adapter for Python.
-- local virtual_env_path = vim.trim(vim.fn.system('poetry config virtualenvs.path'))
-- local virtual_env_directory = vim.trim(vim.fn.system('poetry env list'))
local python_path = 'python'

-- Check to exist virtualenv for corresponding to CWD.
-- if #vim.split(virtual_env_directory, '\n') == 1 then
--     python_path = string.format(
--     "%s/%s/bin/python",
--     virtual_env_path,  -- path to virtualenv directory.
--     virtual_env_directory -- name of virtualenv on current directory.
--     )
-- end

-- The argument to setup is the path to the python installation which contains the debugpy module.
local dap_py = require("dap-python")
dap_py.setup(python_path)

