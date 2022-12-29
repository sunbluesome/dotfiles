-- cmp.lua
-- File for configuring completion options in neovim.

local cmp = require("cmp")
local types = require("cmp.types")
local str = require("cmp.utils.str")
local luasnip = require("luasnip")
local lspkind = require("lspkind")

require("luasnip.loaders.from_vscode").lazy_load()

local check_backspace = function()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end


cmp.setup({
    preselect = cmp.PreselectMode.None,  -- nvim-cmp will not preselect any items.

    mapping = {
        -- horizontal scrolling
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),

        -- horizontal scrolling inside a preview window
        ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),

        -- pull up completions
        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        -- Specify `cmp.config.disable`
        -- if you want to remove the default `<C-y>` mapping.
        ["<C-y>"] = cmp.config.disable,

        -- close completion window
        ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),

        -- Accept currently selected item. If none selected, `select` first item.
        -- Set `select` to `false` to only confirm explicitly selected items.
        ["<CR>"] = cmp.mapping.confirm({ select = false }),

        -- super-tab functionality
        -- cycle through completions, expands and jumps in luasnippet
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expandable() then
                luasnip.expand()
                --[[ elseif luasnip.expand_or_jumpable() then ]]
                --[[     luasnip.expand_or_jump() ]]
            elseif check_backspace() then
                fallback()
            else
                fallback()
            end
        end, {
            "i",
            "s",
        }),

        -- super-tab functionality, reversed
        -- cycle through completions, expands and jumps in luasnippet
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
                --[[ elseif luasnip.jumpable(-1) then ]]
                --[[     luasnip.jump(-1) ]]
            else
                fallback()
            end
        end, {
            "i",
            "s",
        }),
    },

    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body) -- For `luasnip` users.
        end,
    },

    completion = {
        keyword_length = 1  -- The number of characters needed to trigger auto-completion.
    },

    formatting = {
        -- order of items in cmp window
        fields = { "kind", "abbr", "menu" },

        format = lspkind.cmp_format({
            mode = 'symbol', -- show only symbol annotations
            maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

            -- The function below will be called before any actual modifications from lspkind
            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            -- https://github.com/danymat/dotfiles/blob/d91534d08e5a3f6085f8348ec3c41982e9b74941/nvim/.config/nvim/lua/configs/cmp.lua#L35-L60
            before = function(entry, vim_item)
                -- Get the full snippet (and only keep first line)
                local word = entry:get_insert_text()
                if entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet then
                    word = vim.lsp.util.parse_snippet(word)
                end
                word = str.oneline(word)

                if
                    entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet
                    and string.sub(vim_item.abbr, -1, -1) == "~"
                then
                    word = word .. "~"
                end
                vim_item.abbr = word

                -- naming for sources
                vim_item.menu = ({
                    nvim_lsp = "[LSP]",
                    nvim_lua = "[LUA]",
                    luasnip = "[Snippet]",
                    buffer = "[Buffer]",
                    path = "[Path]",
                    git = "[Git]",
                    cmdline = "[CMD]",
                })[entry.source.name]

                return vim_item
            end,
        }),
    },

    disallow_fuzzy_matching = false,  -- Whether to allow fuzzy matching.
    disallow_prefix_unmatching = false, -- Whether to allow fuzzy matching.

    sources = {
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        { name = "nvim_lsp_signature_help" },
        { name = "buffer" },
        { name = "path" , keyword_pattern = "/"},
        { name = "cmdline" },
        { name = "luasnip" },
        { name = "git" },
    },
    confirm_opts = {
        behavior = cmp.ConfirmBehavior.Insert,
        select = false,
    },
    window = {
        documentation = {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        },
    },
    experimental = {
        ghost_text = false,
        native_menu = false,
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
cmp.setup.cmdline({ "/", "?" }, {
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
