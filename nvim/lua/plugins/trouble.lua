return {
    {
        "folke/trouble.nvim",
        version = "*",
        dependencies = "kyazdani42/nvim-web-devicons",
        config = function()
            local trouble = require("trouble").setup{}

            -- keymaps
            -- Map have been already defined in `keymaps.lua`
            Map("n", "<leader>xx", "<cmd>TroubleToggle<cr>")
            Map("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>")
            Map("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>")
            Map("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>")
            Map("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>")
            Map("n", "gR", "<cmd>TroubleToggle lsp_references<cr>")

        end
    },
}

