-- =============================================================================
-- シンタックスハイライト設定 (nvim-treesitter)
-- =============================================================================
-- Neovim 0.11+ では Treesitter ハイライトは組み込み機能です。
-- nvim-treesitter プラグインはパーサーのインストール管理に使用します。
--
-- 使い方:
--   :TSInstall <言語>   - パーサーをインストール
--   :TSUpdate           - 全パーサーを更新
--   :Inspect            - カーソル位置のハイライトグループを確認
--
-- 参考: https://github.com/nvim-treesitter/nvim-treesitter
-- =============================================================================

return {
  -- プラグイン: nvim-treesitter/nvim-treesitter
  "nvim-treesitter/nvim-treesitter",

  -- パーサーの更新コマンドを自動実行
  build = ":TSUpdate",

  -- 遅延読み込みはサポートされていない（公式ドキュメントより）
  lazy = false,

  -- -------------------------------------------------------------------------
  -- nvim-treesitter の設定 (新 API - main ブランチ対応)
  -- 参考: https://github.com/nvim-treesitter/nvim-treesitter/tree/main
  -- -------------------------------------------------------------------------
  config = function()
    -- パーサーのインストール先を設定
    -- nvim-treesitter main ブランチはデフォルトで ~/.cache/nvim にパーサーをインストールする
    -- このディレクトリをランタイムパスに追加する
    local parser_install_dir = vim.fn.stdpath("cache")
    vim.opt.runtimepath:prepend(parser_install_dir)

    -- nvim-treesitter のセットアップ
    require("nvim-treesitter").setup({
      -- パーサーのインストール先
      install_dir = parser_install_dir,
    })

    -- インストールするパーサーのリスト
    local parsers = {
      -- プログラミング言語
      "python",           -- Python (メイン言語)
      "r",                -- R
      "lua",              -- Neovim 設定用
      "bash",             -- シェルスクリプト

      -- データ/設定ファイル
      "sql",              -- SQL クエリ
      "json",             -- JSON データ
      "yaml",             -- YAML 設定ファイル
      "toml",             -- TOML 設定ファイル (pyproject.toml など)

      -- ドキュメント
      "markdown",         -- Markdown
      "markdown_inline",  -- Markdown インライン要素

      -- Vim/Neovim 関連
      "vim",              -- Vim script
      "vimdoc",           -- Vim ヘルプドキュメント
    }

    -- パーサーのインストール（非同期）
    -- 未インストールのパーサーのみインストール
    local missing_parsers = {}
    for _, parser in ipairs(parsers) do
      local ok = pcall(vim.treesitter.language.add, parser)
      if not ok then
        table.insert(missing_parsers, parser)
      end
    end
    if #missing_parsers > 0 then
      require("nvim-treesitter").install(missing_parsers)
    end

    -- -------------------------------------------------------------------------
    -- Neovim 組み込み Treesitter ハイライトを有効化
    -- -------------------------------------------------------------------------
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype

        -- 除外するファイルタイプ
        local disabled_ft = {
          "",           -- 無名バッファ
          "help",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "oil",
          "TelescopePrompt",
        }
        if vim.tbl_contains(disabled_ft, ft) then
          return
        end

        -- 大きなファイルでは無効化 (100KB 以上)
        local max_filesize = 100 * 1024
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return
        end

        -- パーサーが利用可能な場合、treesitter ハイライトを有効化
        local has_parser = pcall(vim.treesitter.get_parser, buf)
        if has_parser then
          vim.treesitter.start(buf)
        end
      end,
    })

    -- -------------------------------------------------------------------------
    -- インクリメンタル選択のキーマップ
    -- -------------------------------------------------------------------------
    vim.keymap.set({ "n", "x" }, "<C-space>", function()
      local ok = pcall(vim.treesitter.get_parser)
      if not ok then
        return
      end

      -- 現在のモードを確認
      local mode = vim.fn.mode()
      if mode == "n" then
        -- ノーマルモード: ビジュアルモードに入ってノード選択
        local node = vim.treesitter.get_node()
        if node then
          local sr, sc, er, ec = node:range()
          vim.cmd("normal! v")
          vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
          vim.cmd("normal! o")
          vim.api.nvim_win_set_cursor(0, { er + 1, ec > 0 and ec - 1 or 0 })
        end
      else
        -- ビジュアルモード: 親ノードに拡大
        local node = vim.treesitter.get_node()
        if node then
          local parent = node:parent()
          if parent then
            local sr, sc, er, ec = parent:range()
            vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
            vim.cmd("normal! o")
            vim.api.nvim_win_set_cursor(0, { er + 1, ec > 0 and ec - 1 or 0 })
          end
        end
      end
    end, { desc = "Treesitter incremental selection" })
  end,
}
