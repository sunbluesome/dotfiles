-- =============================================================================
-- Markdown プレビュー設定 (markview.nvim)
-- =============================================================================
-- markview.nvim は Markdown、HTML、LaTeX、Typst、YAML のプレビューを
-- Neovim 内で直接表示するプラグインです。
--
-- 特徴:
--   - 見出し、リスト、コードブロック、テーブルなどを装飾表示
--   - LaTeX 数式のプレビュー
--   - ハイブリッドモード（編集中は元のテキスト表示）
--   - 分割ビューでのプレビュー
--
-- コマンド:
--   :Markview Toggle   - プレビューのトグル（グローバル）
--   :Markview toggle   - プレビューのトグル（現在のバッファ）
--   :Markview splitToggle - 分割ビューのトグル
--
-- 参考: https://github.com/OXY2DEV/markview.nvim
-- =============================================================================

return {
  "OXY2DEV/markview.nvim",

  -- 遅延読み込みしない（プラグイン自体が遅延読み込み対応済み）
  -- 注意: lazy = true にすると初回表示が遅くなる
  lazy = false,

  -- 依存プラグイン（オプション）
  dependencies = {
    -- アイコン表示用（すでにインストール済み）
    "nvim-tree/nvim-web-devicons",
  },

  -- プラグイン読み込み後に実行される設定
  config = function()
    require("markview").setup({
      -- プレビュー設定
      preview = {
        -- アイコンプロバイダー
        -- "internal": 組み込み（デフォルト）
        -- "mini": mini.icons を使用
        -- "devicons": nvim-web-devicons を使用
        icon_provider = "devicons",

        -- 有効にするファイルタイプ
        filetypes = { "markdown", "quarto", "rmd" },

        -- 無視するバッファタイプ
        ignore_buftypes = { "nofile" },
      },

      -- ハイブリッドモード設定
      -- カーソルがある行は元のマークダウンを表示
      hybrid_mode = {
        -- ハイブリッドモードを有効化
        enable = true,

        -- 編集範囲のモード
        -- "node": Treesitter ノードベース（リストやコードブロック全体を表示）
        -- "range": 行数ベース
        edit_range = "node",
      },

      -- 見出しの装飾設定
      headings = {
        -- 見出しレベルごとのスタイル
        enable = true,

        -- アイコンを表示
        icons = true,
      },

      -- コードブロックの設定
      code_blocks = {
        enable = true,

        -- 言語名を表示
        language_names = true,

        -- 行番号を表示
        line_numbers = false,

        -- 枠線のスタイル
        style = "rounded",
      },

      -- インラインコードの設定
      inline_code = {
        enable = true,
      },

      -- リストの設定
      lists = {
        enable = true,

        -- リストマーカーのアイコン
        -- 順序なしリスト: ●, ○, ■ など
        -- 順序付きリスト: 数字
      },

      -- テーブルの設定
      tables = {
        enable = true,

        -- テーブルの罫線スタイル
        style = "rounded",
      },

      -- チェックボックスの設定
      checkboxes = {
        enable = true,

        -- チェックボックスのアイコン
        checked = "",    -- チェック済み
        unchecked = "",   -- 未チェック
        pending = "",    -- 進行中（[-]）
      },

      -- リンクの設定
      links = {
        enable = true,

        -- ハイパーリンクのアイコン
        hyperlinks = true,

        -- 画像のアイコン
        images = true,
      },

      -- 引用ブロックの設定
      block_quotes = {
        enable = true,
      },

      -- 水平線の設定
      horizontal_rules = {
        enable = true,
      },

      -- LaTeX 数式の設定
      latex = {
        enable = true,
      },
    })

    -- キーマップの追加（オプション）
    vim.keymap.set("n", "<leader>mp", "<cmd>Markview toggle<cr>", { desc = "Toggle Markview preview" })
    vim.keymap.set("n", "<leader>ms", "<cmd>Markview splitToggle<cr>", { desc = "Toggle Markview split" })
  end,
}

