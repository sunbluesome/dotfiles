return {
    {
        "mfussenegger/nvim-dap",
        version = "*",
        dependencies = {
            { "mfussenegger/nvim-dap-python" },
        },
        config = function()
            local dap = require("dap")
            local dap_py = require("dap-python")
            local key = "repl-close"
            local python_path = 'python'

            vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "", linehl = "", numhl = "" })
            vim.fn.sign_define("DapStopped", { text = "", texthl = "", linehl = "", numhl = "" })

            Map('n', '<F5>', ':DapContinue<CR>')
            Map('n', '<F10>', ':DapStepOver<CR>')
            Map('n', '<F11>', ':DapStepInto<CR>')
            Map('n', '<F12>', ':DapStepOut<CR>')
            Map('n', '<leader>b', ':DapToggleBreakpoint<CR>')
            Map('n', '<leader>dr', ':lua require("dap").repl.open()<CR>')

            dap.listeners.after.event_terminated[key] = function()
                dap.repl.close()
            end

            dap.listeners.after.event_exited[key] = function()
                dap.repl.close()
            end

            -- The argument to setup is the path to the python installation which contains the debugpy module.
            dap_py.setup(python_path)

            dap.configurations.python = {
                {
                    -- The first three options are required by nvim-dap
                    name = "Pytest: Current File",
                    type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
                    request = "launch",
                    module = "pytest",
                    args = {
                        "${file}",
                        "-sv",
                    },
                    console = "integratedTerminal",
                }
            }

        end,
    },
}

