return {
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize them global
        globals = {'vim', 'use', 'packer_bootstrap', 'require', 'pairs'},
      },
      workspace = {
        -- An array of abosolute or workspace-relative paths that will be added to the
        -- workspace diagnosis - meaning you will get completion and context from these
        -- library files. Can be a file or directory.
        -- Files included here will have some features disabled such as renaming fields
        -- to prevent accidentally renaming your library files.
        library = {
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.stdpath("config") .. "/lua"] = true,
        }
      },
    },
  },
}
