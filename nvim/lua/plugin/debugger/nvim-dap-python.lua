-- nvim-dap-python.lua
--
-- Config file for setting up nvim-dap debugger adapter for Python.
local python_path = 'python'

-- The argument to setup is the path to the python installation which contains the debugpy module.
local dap_py = require("dap-python")
dap_py.setup(python_path)

