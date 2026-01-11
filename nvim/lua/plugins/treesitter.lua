-- =============================================================================
-- シンタックスハイライト設定 (nvim-treesitter)
-- =============================================================================
-- Neovim 0.11+ では Tree-sitter ハイライトは組み込み機能です。
-- nvim-treesitter プラグインはパーサーのインストール管理に使用します。
--
-- 使い方:
--   :TSInstall <言語>   - パーサーをインストール
--   :TSUpdate           - 全パーサーを更新
--   :TSInstallInfo      - インストール状態を確認
--
-- 参考: https://github.com/nvim-treesitter/nvim-treesitter
-- =============================================================================

return {
  -- プラグイン: nvim-treesitter/nvim-treesitter
  "nvim-treesitter/nvim-treesitter",

  -- パーサーの更新コマンドを自動実行
  build = ":TSUpdate",

  -- 遅延読み込み: ファイルを開いたときに読み込む
  event = { "BufReadPost", "BufNewFile" },

  -- プラグイン読み込み後に実行される設定
  config = function()
    -- -------------------------------------------------------------------------
    -- パーサーのインストール設定
    -- -------------------------------------------------------------------------
    -- 初回起動時にパーサーをインストールするためのリスト
    local ensure_installed = {
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

    -- 起動時にパーサーをインストール（非同期）
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyDone",
      once = true,
      callback = function()
        -- 少し遅延させて起動を妨げないようにする
        vim.defer_fn(function()
          for _, lang in ipairs(ensure_installed) do
            -- パーサーが利用可能かチェック
            local ok = pcall(vim.treesitter.language.add, lang)
            if not ok then
              -- インストールされていなければインストール
              vim.cmd("silent! TSInstall " .. lang)
            end
          end
        end, 100)
      end,
    })

    -- -------------------------------------------------------------------------
    -- Neovim 0.11+ 組み込みハイライト設定
    -- -------------------------------------------------------------------------
    -- ファイルを開いたときに自動的に treesitter ハイライトを有効化
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
    -- Ctrl+Space で選択開始/拡大、Backspace で縮小
    vim.keymap.set("n", "<C-space>", function()
      -- ビジュアルモードに入って選択開始
      local ok = pcall(vim.treesitter.get_parser)
      if ok then
        vim.cmd("normal! v")
        -- treesitter ノードを選択
        local node = vim.treesitter.get_node()
        if node then
          local sr, sc, er, ec = node:range()
          vim.api.nvim_buf_set_mark(0, "<", sr + 1, sc, {})
          vim.api.nvim_buf_set_mark(0, ">", er + 1, ec - 1, {})
          vim.cmd("normal! gv")
        end
      end
    end, { desc = "Start treesitter selection" })
  end,
}
