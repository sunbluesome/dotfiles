-- handlers.lua
-- File for setting server options, such as on_attach,
--
-- References:
-- nvim_lspconfig (about on_attach): https://github.com/neovim/nvim-lspconfig/wiki
-- LSP APIs: https://neovim.io/doc/user/lsp.html
-- To learn what capabilities are available you can run the following command in
-- a buffer with a started LSP client:
-- :lua =vim.lsp.get_active_clients()[1].server_capabilities
-- Full list of features provided by default can be found in lsp-buf.
local cmp_nvim_lsp = require("cmp_nvim_lsp")


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

-- LSP setup ----------------------------------
local M = {}


M.setup = function()
    -- Change diagnostic symbols inthe sign column
    -- See `UI Customization/Change diagnostic symbols in the sign column (gutter)`
    -- in nvim_lspconfig's wiki.
    local signs = { Error = "E", Warn = "W", Hint = "H", Info = "I" }
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
        vim.lsp.handlers.hover, {
        border = "single",
        title = "hover",
    }
    )

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
        border = "single",
    }
    )
end


M.on_attach = function(client, bufnr)
    lsp_keymaps(bufnr)
    lsp_highlight_document(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

return M
