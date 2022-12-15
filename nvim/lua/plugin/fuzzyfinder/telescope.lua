local telescope = require("telescope")
local builtin = require("telescope.builtin")
local dapui = require("dapui")

-- `Map` is defined on core.keymaps.lua
Map('n', '<leader>ff', builtin.find_files)
Map('n', '<leader>fg', builtin.live_grep)
Map('n', '<leader>fb', builtin.buffers)
Map('n', '<leader>fo', builtin.oldfiles)
Map('n', '<leader>fh', builtin.help_tags)

-- telescope-file-browser
local function telescope_buffer_dir()
    return vim.fn.expand("%:p:h")
end
Map("n", "<leader>fe", function()  -- file explorer as fe
    telescope.extensions.file_browser.file_browser({
        path = "%:p:h",
        cwd = telescope_buffer_dir(),
        grouped = true,
        hidden = true,
        previewer = false,
        initial_mode = "normal",
        layout_config = { height = 40 },
    })
end)

-- Dap
Map('n', '<F5>', ':DapContinue<CR>')
Map('n', '<F10>', ':DapStepOver<CR>')
Map('n', '<F11>', ':DapStepInto<CR>')
Map('n', '<F12>', ':DapStepOut<CR>')
Map('n', '<leader>b', ':DapToggleBreakpoint<CR>')
Map('n', '<leader>B',
    ':lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Breakpoint condition: "))<CR>'
)
Map('n', '<leader>lp',
    ':lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>'
)
Map('n', '<leader>dr', ':lua require("dap").repl.open()<CR>')
Map('n', '<leader>dl', ':lua require("dap").run_last()<CR>')
Map('n', '<leader>d', ':lua require("dapui").toggle()<CR>')

-- setup telesope
telescope.setup({
    defaults = {
        -- Will change the title of the preview window dynamically, where it
        -- is supported. For example, the preview window's title could show up as
        -- the full filename.
        dynamic_preview_title = true,
        -- Flex layout swaps between `horizontal` and `vertical` strategies based on
        -- the window width
        layout_strategy = 'flex',
    },
    extensions = {
        file_browser = {
            theme = "dropdown",
            -- disables netrw and use telescope-file-browser in its place
            hijack_netrw = true,
        },
    },
})
