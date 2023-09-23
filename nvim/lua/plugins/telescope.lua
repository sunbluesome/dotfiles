return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {"kyazdani42/nvim-web-devicons", opt = true },
        },
        config = function()
            require("plugins.configs.telescope")
        end,
        event = "VeryLazy"
    },
}
