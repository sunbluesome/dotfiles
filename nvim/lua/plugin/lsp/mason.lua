-- mason.nvim is a Neovim plugin that allows you to easily manage external editor tooling
require("mason").setup()

local ls_to_install = {
    "bashls",
    "dockerls",
    "jsonls",
    "texlab",
    "sumneko_lua",
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.txt#pyright
    -- example: https://zenn.dev/pluck/scraps/27b2a2bd75e6f3
    "pyright",
}

require("mason-lspconfig").setup({
    ensure_installed = ls_to_install
})

local opts = {
    on_attach = require("plugin.lsp.handlers").on_attach,
    capabilities = require("plugin.lsp.handlers").capabilities,
}

-- After setting up mason-lspconfig you may set up servers
local lspconfig = require("lspconfig")
require("mason-lspconfig").setup_handlers {
    -- The first entry (without a key) will be the default handler
    -- and will be called for each installed server that doesn't have
    -- a dedicated handler.
    function(server_name) -- default handler (optional)
        require("lspconfig")[server_name].setup {}
    end,

    -- Next, you can provide a dedicated handler for specific servers.
    ["sumneko_lua"] = function()
        local sumneko_opts = require("plugin.lsp.settings.sumneko_lua")
        opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
        lspconfig.sumneko_lua.setup(opts)
    end,

    ["pyright"] = function()
        local pyright_opts = require("plugin.lsp.settings.pyright")
        opts = vim.tbl_deep_extend("force", pyright_opts, opts)
        lspconfig.pyright.setup(opts)
    end,
}
