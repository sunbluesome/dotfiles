return {
    {
        "kdheepak/lazygit.nvim",
        version = "*",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            Map("n", "<leader>gg", ":LazyGit<CR>")
        end
    },
}

