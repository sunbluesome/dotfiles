-- null-ls.lua
-- Config file for jose-elias-alvarez/null-ls.nvim
--
-- LUA:
--     - stylua for formatting
-- PYTHON:
--     - flake8 for diagnostics
--     - pyptoject_flake8 for diagnostics
--     - mypy for diagnostics
--     - pydocstyle for diagnostics
--     - black for formatting
--     - isort for formatting

local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics


local sources = {
    -- lua
    formatting.stylua,

    -- python
    -- automatically use their config file.
    diagnostics.flake8,
    -- diagnostics.pyproject_flake8,
    diagnostics.mypy,
    -- diagnostics.pydocstyle,
    formatting.black,
    formatting.isort,
}


null_ls.setup({
    debug = false,
    diagnostics_format = "[#{c}] #{m} (#{s})",
    sources = sources,
    temp_dir = "/tmp",
})
