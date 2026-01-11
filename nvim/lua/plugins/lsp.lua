-- =============================================================================
-- LSP (Language Server Protocol) 設定
-- =============================================================================
-- LSP は言語サーバーと通信して、以下の機能を提供します:
--   - コード補完 (nvim-cmp と連携)
--   - 定義へのジャンプ
--   - 参照の検索
--   - リネーム
--   - 診断 (エラー/警告の表示)
--   - フォーマット
--
-- Neovim 0.11+ では vim.lsp.config API を使用します。
--
-- キーマップ:
--   - gd        : 定義へジャンプ
--   - gD        : 宣言へジャンプ
--   - K         : ホバードキュメント表示
--   - gi        : 実装へジャンプ
--   - gr        : 参照一覧
--   - <leader>rn : リネーム
--   - <leader>ca : コードアクション
--   - <leader>f  : フォーマット
--   - [d / ]d   : 前/次の診断へ移動
--
-- 参考:
--   - :help lspconfig-nvim-0.11
--   - https://github.com/williamboman/mason.nvim
-- =============================================================================

return {
  -- mason.nvim: LSP サーバーのインストール管理
  -- :Mason コマンドで UI を開いてサーバーをインストールできる
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },

  -- mason-lspconfig.nvim: mason と lspconfig の橋渡し
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright",    -- Python 型チェック/補完
          "ruff",       -- Python リンター/フォーマッター
          "lua_ls",     -- Lua (Neovim 設定用)
        },
        automatic_installation = true,
      })
    end,
  },

  -- nvim-lspconfig: LSP サーバーの設定
  -- Neovim 0.11+ では vim.lsp.config を使用
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- -----------------------------------------------------------------------
      -- LSP クライアントの機能 (capabilities)
      -- -----------------------------------------------------------------------
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- cmp-nvim-lsp がある場合は capabilities を拡張
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if has_cmp then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      -- -----------------------------------------------------------------------
      -- Neovim 0.11+ vim.lsp.config API を使用した LSP 設定
      -- -----------------------------------------------------------------------

      -- Python: Pyright (型チェック/補完)
      vim.lsp.config.pyright = {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = {
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          "pyrightconfig.json",
          ".git",
        },
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoImportCompletions = true,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      }

      -- Python: Ruff (リンター/フォーマッター)
      vim.lsp.config.ruff = {
        cmd = { "ruff", "server" },
        filetypes = { "python" },
        root_markers = {
          "pyproject.toml",
          "ruff.toml",
          ".ruff.toml",
          ".git",
        },
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          -- Ruff のホバー機能を無効化 (Pyright を優先)
          client.server_capabilities.hoverProvider = false
        end,
      }

      -- Lua: lua_ls (Neovim 設定用)
      vim.lsp.config.lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = {
          ".luarc.json",
          ".luarc.jsonc",
          ".luacheckrc",
          ".stylua.toml",
          "stylua.toml",
          "selene.toml",
          "selene.yml",
          ".git",
        },
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      }

      -- LSP サーバーを有効化
      vim.lsp.enable({ "pyright", "ruff", "lua_ls" })

      -- -----------------------------------------------------------------------
      -- LSP キーマップ (LSP がアタッチされたときのみ有効)
      -- -----------------------------------------------------------------------
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(args)
          local bufnr = args.buf

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          -- ナビゲーション
          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
          map("n", "gr", vim.lsp.buf.references, "Go to references")
          map("n", "gt", vim.lsp.buf.type_definition, "Go to type definition")

          -- ドキュメント/情報
          map("n", "K", vim.lsp.buf.hover, "Hover documentation")
          map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
          map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")

          -- リファクタリング
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")

          -- フォーマット
          map("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
          end, "Format document")

          -- 診断ナビゲーション
          map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
          map("n", "<leader>e", vim.diagnostic.open_float, "Show diagnostic")
          map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostic list")
        end,
      })

      -- -----------------------------------------------------------------------
      -- 診断の表示設定
      -- -----------------------------------------------------------------------
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          spacing = 4,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- 診断アイコンの設定
      local signs = {
        Error = " ",
        Warn = " ",
        Hint = " ",
        Info = " ",
      }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    end,
  },
}
