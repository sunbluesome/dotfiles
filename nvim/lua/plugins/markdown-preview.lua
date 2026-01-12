-- =============================================================================
-- Markdown プレビュー設定 (markdown-preview.nvim)
-- =============================================================================
-- ブラウザでMarkdownをリアルタイムプレビューするプラグイン
--
-- 特徴:
--   - KaTeX による数式レンダリング（$...$, $$...$$）
--   - Mermaid ダイアグラム対応
--   - 同期スクロール
--   - バッファ保存時にプレビュー更新
--
-- コマンド:
--   :MarkdownPreview       - プレビューを開始
--   :MarkdownPreviewStop   - プレビューを停止
--   :MarkdownPreviewToggle - プレビューのトグル
--
-- 参考: https://github.com/iamcco/markdown-preview.nvim
-- =============================================================================

return {
  "iamcco/markdown-preview.nvim",

  -- Markdownファイルを開いた時に読み込み
  ft = { "markdown" },

  -- コマンドでも読み込み可能
  cmd = {
    "MarkdownPreview",
    "MarkdownPreviewStop",
    "MarkdownPreviewToggle",
  },

  -- プラグインのビルド（Node.js必要）
  build = "cd app && npm install",

  init = function()
    -- 有効にするファイルタイプ
    vim.g.mkdp_filetypes = { "markdown" }

    -- バッファ保存時のみプレビューを更新（1 = 有効）
    -- 0 にするとカーソル移動でリアルタイム更新
    vim.g.mkdp_refresh_slow = 1

    -- プレビューを開くブラウザ（空文字でシステムデフォルト）
    vim.g.mkdp_browser = ""

    -- プレビューページのタイトル
    -- ${name} はファイル名に置換される
    vim.g.mkdp_page_title = "「${name}」"

    -- ファイルを開いた時に自動でプレビューを開始しない
    vim.g.mkdp_auto_start = 0

    -- 別のバッファに移動した時にプレビューを閉じない
    vim.g.mkdp_auto_close = 0

    -- DevContainer内かどうかを判定
    -- (REMOTE_CONTAINERS環境変数またはDockerの.dockerenv存在で判定)
    local in_container = vim.fn.getenv("REMOTE_CONTAINERS") ~= vim.NIL
      or vim.fn.filereadable("/.dockerenv") == 1

    if in_container then
      -- DevContainer内の設定
      -- プレビューサーバーのポートを固定
      vim.g.mkdp_port = "8090"

      -- 外部からのアクセスを許可
      vim.g.mkdp_open_to_the_world = 1

      -- ブラウザを開かない（コンテナ内にはブラウザがない）
      -- 手動で http://localhost:8090 にアクセス
      vim.g.mkdp_browser = "echo"

      -- 起動時にURLを表示
      vim.g.mkdp_echo_preview_url = 1
    else
      -- ローカル環境の設定
      vim.g.mkdp_port = ""
      vim.g.mkdp_browser = ""
    end

    -- プレビューオプション
    vim.g.mkdp_preview_options = {
      -- Mermaid ダイアグラムのオプション
      maid = {},
      -- シーケンス図のテーマ
      sequence_diagrams = {},
      -- フローチャートのオプション
      flowchart_diagrams = {},
      -- コンテンツを中央寄せしない
      disable_sync_scroll = 0,
      -- 同期スクロールのタイプ
      -- "middle": プレビューの中央に表示
      -- "top": プレビューの上部に表示
      -- "relative": エディタとの相対位置を維持
      sync_scroll_type = "middle",
    }

    -- カスタムCSS（空文字でデフォルト）
    vim.g.mkdp_markdown_css = ""

    -- カスタムハイライトCSS
    vim.g.mkdp_highlight_css = ""
  end,

  config = function()
    -- キーマップの設定
    -- <leader>mp は markview.nvim（インエディタプレビュー）で使用
    -- <leader>mb でブラウザプレビュー
    vim.keymap.set("n", "<leader>mb", "<cmd>MarkdownPreviewToggle<cr>", {
      desc = "Toggle Markdown browser preview",
    })
  end,
}
