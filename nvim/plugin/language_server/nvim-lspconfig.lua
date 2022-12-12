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

-- After setting up mason-lspconfig you may set up servers
require("mason-lspconfig").setup_handlers {
    -- The first entry (without a key) will be the default handler
    -- and will be called for each installed server that doesn't have
    -- a dedicated handler.
    function (server_name) -- default handler (optional)
        require("lspconfig")[server_name].setup {}
    end,
    -- Next, you can provide a dedicated handler for specific servers.
    -- For example, a handler override for the `rust_analyzer`:
    -- ["rust_analyzer"] = function ()
    --     require("rust-tools").setup {}
    -- end
}
