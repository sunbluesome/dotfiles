return {
    {
        "phaazon/hop.nvim",
        branch = 'v2', -- optional but strongly recommended
        version = "*",
        config = function()
            -- you can configure Hop the way you like here; see :h hop-config
            local hop = require('hop')
            local directions = require('hop.hint').HintDirection
            hop.setup({keys='etovxqpdygfblzhckisuran'})
            Map('n', 'm', "<cmd>HopWord<CR>")
        end
    },
}

