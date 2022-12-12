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

        -- plugins
        -- statusline
        use {
            'nvim-lualine/lualine.nvim',
            requires = {'kyazdani42/nvim-web-devicons', opt = true }
        }

        -- treesitter
        use {
            'nvim-treesitter/nvim-treesitter',
            run = function()
                local installer = require('nvim-treesitter.install')
                local ts_update = installer.update({with_sync = true})
                ts_update()
            end,
        }

        -- telescope
        use {
            "nvim-telescope/telescope.nvim",
            requires = {
                {'nvim-lua/plenary.nvim'},  -- Required dependency
                {'kyazdani42/nvim-web-devicons', opt = true },
            },
        }

        -- colorscheme
        use { "EdenEast/nightfox.nvim" }

        -- LSP
        -- Easily install and manage LSP servers, DAP servers, linters, and formatters.
        use { "williamboman/mason.nvim"}
        use { "williamboman/mason-lspconfig.nvim" }
        use { "neovim/nvim-lspconfig" } -- enable LSP
        use { "mfussenegger/nvim-dap" } -- debug adaptor protocol
        use { "jose-elias-alvarez/null-ls.nvim" } -- formatter and linter


        if packer_bootstrap then
            require('packer').sync()
        end
    end,
})
