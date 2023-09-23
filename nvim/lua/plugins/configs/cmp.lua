-- cmp.lua
-- File for configuring completion options in neovim.
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

local cmp = require("cmp")
local types = require("cmp.types")
local str = require("cmp.utils.str")
local luasnip = require("luasnip")
local lspkind = require("lspkind")


mason.setup()
mason_lspconfig.setup({
    ensure_installed = {
        "bashls",
        "dockerls",
        "jsonls",
        "pyright",
    }
})


-- Completion settings ----------------------------------------------------------------
lspkind.init({
    -- DEPRECATED (use mode instead): enables text annotations
    --
    -- default: true
    -- with_text = true,

    -- defines how annotations are shown
    -- default: symbol
    -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
    mode = 'symbol_text',

    -- default symbol map
    -- can be either 'default' (requires nerd-fonts font) or
    -- 'codicons' for codicon preset (requires vscode-codicons font)
    --
    -- default: 'default'
    preset = 'codicons',

    -- override preset symbols
    --
    -- default: {}
    symbol_map = {
        Text = "󰉿",
        Method = "󰆧",
        Function = "󰊕",
        Constructor = "",
        Field = "󰜢",
        Variable = "󰀫",
        Class = "󰠱",
        Interface = "",
        Module = "",
        Property = "󰜢",
        Unit = "󰑭",
        Value = "󰎠",
        Enum = "",
        Keyword = "󰌋",
        Snippet = "",
        Color = "󰏘",
        File = "󰈙",
        Reference = "󰈇",
        Folder = "󰉋",
        EnumMember = "",
        Constant = "󰏿",
        Struct = "󰙅",
        Event = "",
        Operator = "󰆕",
        TypeParameter = "",
        Copilot = "",
    },
})

require("luasnip.loaders.from_vscode").lazy_load()

local check_backspace = function()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end


--  Global setup
cmp.setup({
    preselect = cmp.PreselectMode.None,  -- nvim-cmp will not preselect any items.

    mapping = {
        -- horizontal scrolling
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),

        -- horizontal scrolling inside a preview window
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),

        -- close completion window
        ["<C-[>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),

        -- Accept currently selected item. If none selected, `select` first item.
        -- Set `select` to `false` to only confirm explicitly selected items.
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
    },

    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body) -- For `luasnip` users.
        end,
    },

    completion = {
        keyword_length = 1  -- The number of characters needed to trigger auto-completion.
    },

    sources = {
        { name = "nvim_lsp" },
        { name = "copilot" },
        { name = "nvim_lua" },
        { name = "nvim_lsp_signature_help" },
        { name = "buffer" },
        { name = "path" , keyword_pattern = "/"},
        { name = "cmdline" },
        { name = "luasnip" },
        { name = "git" },
    },

    formatting = {
        -- order of items in cmp window
        fields = { "kind", "abbr", "menu" },

        format = lspkind.cmp_format({
            mode = 'symbol', -- show only symbol annotations
            maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

            menu = {
                nvim_lsp = "[LSP]",
                copilot = "[Copilot]",
                luasnip = "[Snippet]",
                buffer = "[Buffer]",
                path = "[Path]",
                git = "[Git]",
                cmdline = "[CMD]",
                nvim_lua = "[LUA]",
            }
        }),
    },

    disallow_fuzzy_matching = false,  -- Whether to allow fuzzy matching.
    disallow_prefix_unmatching = false, -- Whether to allow fuzzy matching.

    confirm_opts = {
        behavior = cmp.ConfirmBehavior.Insert,
        select = false,
    },
    window = {
        documentation = {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            max_height = 100,
        },
    },
})


-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({
        { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
        { name = "buffer" },
    })
})
cmp.setup.filetype("python", {
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
    }, {
        { name = "luasnip" },
    }, {
        { name = "nvim_lsp_signature_help" },
    }, {
        { name = "path" },
    })
})
cmp.setup.filetype("markdown", {
    sources = cmp.config.sources({
        { name = "path" },
    }, {
        { name = "buffer" },
    })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.buffer({ "/", "?"}, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" }
    }
})

-- Use cmdline & path source for ":" (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "path" }
    }, {
        { name = "cmdline" }
    })
})


-- LSP settings -----------------------------------------------------------------------
-- Change diagnostic symbols inthe sign column -----------------
-- See `UI Customization/Change diagnostic symbols in the sign column (gutter)`
-- in nvim_lspconfig's wiki.
local signs = { Error = "", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- You can configure diagnostic options globally.
-- See :help vim.diagnostic.config for more advanced customization options.
vim.diagnostic.config({
    virtual_text = true, -- shows error message at the end of an line in which it occured
    underline = true,
    severity_sort = true,
    float = {
        source = "always",
        header = "",
        prefix = "",
    },
    update_in_insert = false,
})

-- setup handers
-- See :help vim.lsp.handers
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, { border = "single", title = "hover" }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, { border = "single" }
)
-- END: Change diagnostic symbols inthe sign column -----------------

-- LSP Config -------------------------------------------------------
local function lsp_keymaps(bufnr)
    local set_keymap = vim.api.nvim_buf_set_keymap
    local opts = { noremap = true, silent = true }
    set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    set_keymap(bufnr, "n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
    set_keymap(bufnr, "n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
    set_keymap(bufnr, "n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
    set_keymap(bufnr, "n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
    set_keymap(bufnr, "n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    set_keymap(bufnr, "n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    set_keymap(bufnr, "n", "gr", "<cmd>lua.vim.lsp.buf.references()<CR>", opts)
    set_keymap(bufnr, "n", "<space>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
    set_keymap(bufnr, "n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
    set_keymap(bufnr, "n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
    set_keymap(bufnr, "n", "<space>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
    set_keymap(bufnr, "n", "<space>fmt", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
end

local function lsp_highlight_document(client)
    -- Set autocommands conditional on server_capabilities
    if client.server_capabilities.document_highlight then
        vim.api.nvim_exec(
            [[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]]       ,
            false
        )
    end
end



local function on_attach(client, bufnr)
    lsp_keymaps(bufnr)
    lsp_highlight_document(client)
end


local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
default_capabilities = cmp_nvim_lsp.default_capabilities(capabilities)


local opts = {
    on_attach = on_attach,
    capabilities = default_capabilities,
}


mason_lspconfig.setup_handlers {
    -- The first entry (without a key) will be the default handler
    -- and will be called for each installed server that doesn't have
    -- a dedicated handler.
    function(server_name) -- default handler (optional)
        require("lspconfig")[server_name].setup {}
    end,

    -- Next, you can provide a dedicated handler for specific servers.
    -- ["sumneko_lua"] = function()
    --     local sumneko_opts = require("plugin.lsp.settings.sumneko_lua")
    --     opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
    --     lspconfig.sumneko_lua.setup(opts)
    -- end,

    ["pyright"] = function()
        local pyright_opts = {
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        diagnosticMode = "workspace",
                        typeCheckingMode = "off",
                        extraPaths = {
                            ".",
                            "./src",
                            "./module",
                            "./modules",
                        }
                    },
                },
            },
        }
        opts = vim.tbl_deep_extend("force", pyright_opts, opts)
        lspconfig.pyright.setup(opts)
    end,
}
-- END: LSP Config ---------------------------------------------------
