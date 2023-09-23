return {
    {
        "nvim-treesitter/nvim-treesitter",
        version = "*",
        config = function()
            local installer = require('nvim-treesitter.install')
            local ts_update = installer.update({with_sync = true})
            ts_update()
        end,
    },
}


