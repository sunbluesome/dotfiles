-- init.lua
-- main init file for lsp configuration.

require("lspconfig")
require("plugin.lsp.mason")
require("plugin.lsp.handlers").setup()
require("plugin.lsp.lsp_signature").setup()
