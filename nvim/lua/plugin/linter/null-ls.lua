-- null-ls.lua
-- Config file for jose-elias-alvarez/null-ls.nvim
--
-- LUA:
--     - stylua for formatting
-- PYTHON:
--     - black for formatting
--     - isort for formatting
--     - flake8 for diagnostics
--     - mypy for diagnostics

local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

local sources = {
    -- lua
    formatting.stylua,

    -- python
    formatting.black.with({
        extra_args = {
            "--fast",
        }
    }),
    diagnostics.flake8.with({
        extra_args = {
            "--max-line-length",
            "88",
            "--extend-ignore",
            "D100",
            "D104",
            "D401",
            "E203", -- E203: ignored because this causes conflict with `black`. Ref: https://black.readthedocs.io/en/stable/the_black_code_style/current_style.html#slices
            "W503", -- W503: ignored because this rule goes against PEP8. Ref: https://www.flake8rules.com/rules/W503.html
        },
    }),
    -- diagnostics.pyproject_flake8.with({
    --     extra_args = {
    --         "--max-line-length",
    --         "88",
    --         "--ignore",
    --         "D100",
    --         "D104",
    --         "D401",
    --         "E203", -- E203: ignored because this causes conflict with `black`. Ref: https://black.readthedocs.io/en/stable/the_black_code_style/current_style.html#slices
    --         "W503", -- W503: ignored because this rule goes against PEP8. Ref: https://www.flake8rules.com/rules/W503.html
    --     },
    -- }),
    diagnostics.mypy.with({
        extra_args = {
            "--no-implicit-optional",
            "--ignore-missing-imports",
            "--check-untyped-defs",
            "--disallow-untyped-defs",
            "--warn-unused-ignores",
            "--exclude",
            "/(site-packages|node_modules|__pycache__|tests|\\..*)/$",
        }
    }),
    diagnostics.pydocstyle.with({
        extra_args = {
            "--convention",
            "numpy",
        }
    }),
    formatting.isort.with({
        extra_args = {
            "--line-length",
            "88",
            "--profile",
            "black",
        }
    }),
}


null_ls.setup({
    debug = false,
    diagnostics_format = "[#{c}] #{m} (#{s})",
    sources = sources
})
