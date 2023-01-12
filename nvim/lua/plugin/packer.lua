-- Automatically install packer
local fn = vim.fn
local install_path = fn.stdpath("data") .. '/site/pack/packer/start/packer.nvim'

-- install if install_path is empty
if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
        'git',
        'clone',
        '--depth',
        '1',
        'https://github.com/wbthomason/packer.nvim',
        install_path,
    })

    print("Installing packer...")
    vim.cmd [[packadd packer.nvim]]
    print("done. Please restart.")
end

-- Autocommand to reload neovim whenever plugins.lua is updated
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])


-- return early if a protected call fails.
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end


packer.startup({
    function()
        -- must be first
        use 'wbthomason/packer.nvim'

        -- many plugins use this.
        use { 'kyazdani42/nvim-web-devicons' }

        -- easymotion
        use {
          'phaazon/hop.nvim',
          branch = 'v2', -- optional but strongly recommended
          config = function()
            -- you can configure Hop the way you like here; see :h hop-config
            require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
          end
        }

        -- bufferline -----------------------------------------------------------------
        use {
            'akinsho/bufferline.nvim',
            tag = "v3.*",
            requires = 'nvim-tree/nvim-web-devicons'
        }

        -- status line ----------------------------------------------------------------
        use {
            'nvim-lualine/lualine.nvim',
            requires = {'kyazdani42/nvim-web-devicons', opt = true }
        }

        -- treesitter -----------------------------------------------------------------
        use {
            'nvim-treesitter/nvim-treesitter',
            run = function()
                local installer = require('nvim-treesitter.install')
                local ts_update = installer.update({with_sync = true})
                ts_update()
            end,
        }
        -- bracket colorizer
        use { "p00f/nvim-ts-rainbow" }

        -- telescope ------------------------------------------------------------------
        use {
            "nvim-telescope/telescope.nvim",
            requires = {
                {'nvim-lua/plenary.nvim'},  -- Required dependency
                {'kyazdani42/nvim-web-devicons', opt = true },
            },
        }
        use { "nvim-telescope/telescope-file-browser.nvim" }

        -- colorscheme ----------------------------------------------------------------
        use { "EdenEast/nightfox.nvim" }

        -- LSP ------------------------------------------------------------------------
        -- Easily install and manage LSP servers, DAP servers, linters, and formatters.
        use { "williamboman/mason.nvim" }
        use { "williamboman/mason-lspconfig.nvim" }
        use { "neovim/nvim-lspconfig" } -- enable LSP
        use { "jose-elias-alvarez/null-ls.nvim" } -- formatter and linter
        use { "ray-x/lsp_signature.nvim" } -- help with type hinting
        -- This tiny plugin adds vscode-like pictograms to neovim built-in lsp
        use { "onsails/lspkind.nvim" }
        -- A pretty list for showing diagnostics, references, telescope results,
        -- quickfix and location lists to help you solve all the trouble your code is
        -- causing.
        use {
            "folke/trouble.nvim",
            requires = "kyazdani42/nvim-web-devicons",
            config = function() require("trouble").setup {} end
        }

        -- Completion
        use { "hrsh7th/nvim-cmp" } -- The completion plugin
        use { "hrsh7th/cmp-nvim-lsp" } -- source for neovim's built-in lsp
        use { "hrsh7th/cmp-nvim-lua" } -- source for neovim's Lua api
        use { "hrsh7th/cmp-buffer" } -- buffer completions
        use { "hrsh7th/cmp-path" } -- path completions
        use { "hrsh7th/cmp-cmdline" } -- cmdline completions
        use { "saadparwaiz1/cmp_luasnip" } -- snippet completions
        -- requires nvim-lua/plenary.nvim but already installed above.
        use { "petertriho/cmp-git" } -- git completions,
        use {
            "windwp/nvim-autopairs",
            config = function() require("nvim-autopairs").setup {} end
        }

        -- snippets
        use { "L3MON4D3/LuaSnip" } --snippet engine
        use { "rafamadriz/friendly-snippets" } -- a bunch of snippets to use

        -- Git
        use { "lewis6991/gitsigns.nvim" }
        -- Packer
        use { "sindrets/diffview.nvim", requires = "nvim-lua/plenary.nvim" }

        -- terminal -------------------------------------------------------------------
        use {"akinsho/toggleterm.nvim", tag = '*', config = function()
            require("toggleterm").setup()
        end}

        -- DAP (Debugger Adaptor Protocol) --------------------------------------------
        use { "mfussenegger/nvim-dap" }
        use { "rcarriga/nvim-dap-ui" }
        use { "theHamsta/nvim-dap-virtual-text" }
        use { "nvim-telescope/telescope-dap.nvim"}
        use { "mfussenegger/nvim-dap-python" }

        -- Others
        use {
            "numToStr/Comment.nvim",
            config = function()
                require('Comment').setup()
            end
        }

        if packer_bootstrap then
            require('packer').sync()
        end
    end,
})
