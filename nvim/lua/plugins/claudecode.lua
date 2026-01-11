-- =============================================================================
-- Claude Code 連携設定 (claudecode.nvim)
-- =============================================================================
-- claudecode.nvim は Claude Code CLI と Neovim を連携させるプラグインです。
-- Coder社が開発・メンテナンスしています。
--
-- 主な機能:
--   - Claude Code の /vim コマンドで Neovim と連携
--   - 選択範囲を Claude Code に送信
--   - Claude Code からのファイル差分表示
--   - ターミナル統合
--
-- 使い方:
--   1. Neovim を起動すると自動的に WebSocket サーバーが起動
--   2. Claude Code CLI を起動すると自動的に接続される
--   3. 以下のコマンド/キーマップが使用可能:
--
-- コマンド:
--   :ClaudeCode           - Claude Code ターミナルをトグル
--   :ClaudeCodeStatus     - 接続状態を確認
--   :ClaudeCodeSend       - 選択範囲を Claude Code に送信
--   :ClaudeCodeTreeAdd    - ファイルツリーからコンテキストに追加
--   :ClaudeCodeAdd        - 現在のファイル/選択範囲をコンテキストに追加
--
-- デフォルトキーマップ:
--   <leader>ac - Claude Code ターミナルをトグル
--   <leader>as - 選択範囲を Claude Code に送信
--   <leader>af - 現在のファイルをコンテキストに追加
--
-- 参考: https://github.com/coder/claudecode.nvim
-- =============================================================================

return {
  -- プラグイン: coder/claudecode.nvim
  -- 注意: "coder/claudecode.nvim" が正しいリポジトリ名
  "coder/claudecode.nvim",

  -- 遅延読み込み: 起動後少し遅れて読み込む
  -- Claude Code との連携は即座に必要ではないので VeryLazy で読み込み
  event = "VeryLazy",

  -- プラグイン読み込み後に実行される設定
  config = function()
    require("claudecode").setup({
      -- ログレベル ("debug", "info", "warn", "error")
      -- 問題が発生した場合は "debug" に変更してデバッグ
      log_level = "info",

      -- 自動起動設定
      -- true: Neovim 起動時に自動的に WebSocket サーバーを起動
      auto_start = true,

      -- ターミナルで実行するコマンド
      -- Claude Code CLI のパスを明示的に指定
      terminal_cmd = "claude",

      -- ターミナル設定
      terminal = {
        -- ターミナルプロバイダー
        -- "native": 組み込みのターミナル（デフォルト）
        -- "snacks": snacks.nvim を使用
        -- "toggleterm": toggleterm.nvim を使用（要別途設定）
        provider = "native",

        -- ターミナルの表示位置
        -- "left" または "right"
        split_side = "right",

        -- ターミナルの幅（画面幅に対する割合、0.0〜1.0）
        split_width_percentage = 0.4,

        -- ターミナル表示時にフォーカスを移すか
        show_native_term_exit_tip = true,
      },

      -- キーマップ設定
      -- false にするとキーマップを無効化（自分で設定する場合）
      keymaps = {
        -- Claude Code ターミナルをトグル
        toggle = {
          normal = "<leader>cc",  -- ノーマルモードで <leader>ac
        },
        -- 選択範囲を Claude Code に送信
        send_selection = {
          visual = "<leader>cs",  -- ビジュアルモードで <leader>as
        },
        -- 現在のファイルをコンテキストに追加
        add_file = {
          normal = "<leader>ca",  -- ノーマルモードで <leader>af
          visual = "<leader>ca",  -- ビジュアルモードで <leader>af（選択範囲を追加）
        },
      },

      -- diff 表示の設定
      diff = {
        -- diff ウィンドウを開いたときに自動的にフォーカスするか
        auto_focus = true,
      },
    })
  end,
}

