-- =============================================================================
-- ファイラー設定 (oil.nvim)
-- =============================================================================
-- oil.nvim はディレクトリをバッファとして編集できるファイラーです。
-- 通常の Vim 操作でファイルの作成、削除、リネーム、移動ができます。
--
-- 使い方:
--   - Ctrl+e でカレントディレクトリを開く
--   - "-" キーで親ディレクトリを開く
--   - q で oil を閉じる
--   - ディレクトリ内でファイル名を編集して :w で保存 = リネーム
--   - dd でファイルを削除 (保存時に実行される)
--   - o で新規ファイル作成
--   - Enter でファイルを開く
--
-- 参考: https://github.com/stevearc/oil.nvim
-- =============================================================================

return {
  -- プラグイン: stevearc/oil.nvim
  "stevearc/oil.nvim",

  -- アイコン表示のための依存プラグイン
  dependencies = { "nvim-tree/nvim-web-devicons" },

  -- 遅延読み込み: キーを押したときに読み込む
  keys = {
    { "<C-e>", "<CMD>Oil --float<CR>", desc = "Open current directory (float)" },
    { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
  },

  -- プラグイン読み込み後に実行される設定
  config = function()
    require("oil").setup({
      -- oilを開いたときに自動でプレビューを表示
      watch_for_changes = true,
      -- デフォルトのファイラーとして使用するか
      -- true にすると netrw の代わりに oil が開く
      default_file_explorer = true,

      -- バッファ内のカラム表示設定
      columns = {
        "icon",        -- ファイルタイプアイコン
        -- "permissions", -- パーミッション表示（必要なら追加）
        -- "size",        -- ファイルサイズ
        -- "mtime",       -- 更新日時
      },

      -- バッファローカルオプション
      buf_options = {
        buflisted = false,    -- バッファリストに表示しない
        bufhidden = "hide",   -- 非表示時にバッファを隠す
      },

      -- ウィンドウローカルオプション
      win_options = {
        wrap = false,              -- 行の折り返しを無効
        signcolumn = "no",         -- サインカラムを非表示
        cursorcolumn = false,      -- カーソル列のハイライトを無効
        foldcolumn = "0",          -- 折りたたみカラムを非表示
        spell = false,             -- スペルチェックを無効
        list = false,              -- 不可視文字の表示を無効
        conceallevel = 3,          -- conceal を完全に有効化
        concealcursor = "nvic",    -- 全モードで conceal を適用
      },

      -- ファイル表示オプション
      view_options = {
        -- 隠しファイル（ドットファイル）を表示するか
        show_hidden = true,

        -- 常に最初に表示されるファイル/ディレクトリ
        -- ".." を先頭に表示することで親ディレクトリへの移動が簡単に
        is_always_hidden = function(name, bufnr)
          -- 特定のファイルを常に非表示にする場合はここで設定
          -- 例: return name == ".git"
          return false
        end,
      },

      -- フローティングウィンドウ設定
      float = {
        -- ウィンドウ幅のパディング
        padding = 2,

        -- ウィンドウの最大幅/高さ (0.0 - 1.0 の割合)
        max_width = 0.8,
        max_height = 0.8,

        -- ウィンドウの境界線スタイル
        border = "rounded",

        -- プレビューウィンドウの位置: "auto", "left", "right", "above", "below"
        preview_split = "right",

        -- 内側に勝手に表示されるウィンドウタイトル
        win_options = {
          winblend = 0,  -- 透明度 (0 = 不透明)
        },
      },

      -- プレビューウィンドウ設定（自動プレビュー）
      preview_win = {
        -- カーソル移動時にプレビューを自動更新
        update_on_cursor_moved = true,
        -- プレビューを無効にするファイル（大きなファイルなど）
        disable_preview = function(filename)
          local max_size = 1024 * 1024 -- 1MB
          local stat = vim.loop.fs_stat(filename)
          if stat and stat.size > max_size then
            return true
          end
          return false
        end,
        win_options = {},
      },

      -- プレビュー設定
      preview = {
        -- プレビューの最大幅/高さ
        max_width = 0.9,
        max_height = 0.9,
        -- プレビューウィンドウの境界線
        border = "rounded",
        win_options = {
          winblend = 0,
        },
      },

      -- 確認プロンプトの設定
      -- 削除やリネームなど破壊的操作時の確認
      skip_confirm_for_simple_edits = false,

      -- キーマッピング
      keymaps = {
        ["g?"] = "actions.show_help",      -- ヘルプ表示
        ["<CR>"] = "actions.select",       -- ファイルを開く
        -- ["<C-v>"] = "actions.select_vsplit", -- 垂直分割で開く
        -- ["<C-s>"] = "actions.select_split",  -- 水平分割で開く
        ["<C-t>"] = "actions.select_tab",    -- 新しいタブで開く
        -- ["<C-p>"] = "actions.preview",       -- プレビュー
        -- ["<C-c>"] = "actions.close",         -- 閉じる
        ["q"] = "actions.close",             -- q で閉じる
        ["<C-r>"] = "actions.refresh",       -- 更新
        ["-"] = "actions.parent",            -- 親ディレクトリへ
        ["_"] = "actions.open_cwd",          -- カレントディレクトリを開く
        ["`"] = "actions.cd",                -- cd
        ["~"] = "actions.tcd",               -- tcd (タブローカル cd)
        ["gs"] = "actions.change_sort",      -- ソート順変更
        ["gx"] = "actions.open_external",    -- 外部プログラムで開く
        ["g."] = "actions.toggle_hidden",    -- 隠しファイル表示切替
        -- ["P"] = "actions.preview",           -- プレビュートグル（大文字P）
      },
    })

    -- oilを開いたときに自動でプレビューウィンドウを表示
    vim.api.nvim_create_autocmd("User", {
      pattern = "OilEnter",
      callback = vim.schedule_wrap(function(args)
        local oil = require("oil")
        if vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry() then
          oil.open_preview()
        end
      end),
    })
  end,
}

