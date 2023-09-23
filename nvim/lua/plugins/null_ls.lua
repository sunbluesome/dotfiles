return {
    {
        "jose-elias-alvarez/null-ls.nvim",
        version = "*",
        config = function()
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


            local temp_dir = "/tmp"
            if vim.loop.os_uname().sysname == "Windows_NT" then
                temp_dir = "%USERPROFILE%\\AppData\\Local\\Temp"
            end

            null_ls.setup({
                debug = false,
                diagnostics_format = "[#{c}] #{m} (#{s})",
                sources = sources,
                -- temp_dir = temp_dir,
            })
        end
    },
}

