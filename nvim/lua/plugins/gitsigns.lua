-- =============================================================================
-- Git 変更表示設定 (gitsigns.nvim)
-- =============================================================================
-- gitsigns.nvim はサインカラム (左端) に Git の変更状態を表示します。
-- 追加行、変更行、削除行をひと目で確認できます。
--
-- 表示される記号:
--   │ : 追加された行
--   │ : 変更された行
--   _ : 削除された行 (下線)
--   ‾ : 削除された行 (上線、ファイル先頭)
--   ~ : 変更かつ削除された行
--
-- キーマップ:
--   - ]c / [c      : 次/前の hunk (変更ブロック) へ移動
--   - <leader>hs   : ステージング (hunk stage)
--   - <leader>hr   : リセット (hunk reset)
--   - <leader>hp   : プレビュー (hunk preview)
--   - <leader>hb   : blame 表示 (現在行)
--   - <leader>hd   : diff 表示
--
-- 参考: https://github.com/lewis6991/gitsigns.nvim
-- =============================================================================

return {
  -- プラグイン: lewis6991/gitsigns.nvim
  "lewis6991/gitsigns.nvim",

  -- 遅延読み込み: ファイルを開いたときに読み込む
  event = { "BufReadPre", "BufNewFile" },

  -- プラグイン読み込み後に実行される設定
  config = function()
    require("gitsigns").setup({
      -- サインカラムに表示する記号
      signs = {
        add = { text = "│" },          -- 追加された行
        change = { text = "│" },       -- 変更された行
        delete = { text = "_" },       -- 削除された行
        topdelete = { text = "‾" },    -- 先頭で削除された行
        changedelete = { text = "~" }, -- 変更後に削除された行
        untracked = { text = "┆" },    -- 追跡されていない行
      },

      -- ステージングされた変更のサイン表示
      signs_staged = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },

      -- ステージングされた変更もハイライトする
      signs_staged_enable = true,

      -- サインカラムにサインを表示
      signcolumn = true,

      -- 行番号のハイライトは無効
      numhl = false,

      -- 行全体のハイライトは無効
      linehl = false,

      -- 変更された単語のハイライトは無効
      word_diff = false,

      -- ファイル監視の設定
      watch_gitdir = {
        -- Git ディレクトリの変更を監視する間隔 (ms)
        follow_files = true,
      },

      -- バッファにアタッチする条件
      attach_to_untracked = true,

      -- 現在行の blame 情報を表示するかどうか
      current_line_blame = false,

      -- 現在行の blame 表示オプション
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 1000,
        ignore_whitespace = false,
      },

      -- 現在行の blame のフォーマット
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",

      -- サイン表示の優先度
      sign_priority = 6,

      -- 更新間隔 (ms)
      update_debounce = 100,

      -- ステータスフォーマッター
      status_formatter = nil,

      -- 大きなファイルでは無効化 (行数)
      max_file_length = 40000,

      -- プレビューウィンドウの設定
      preview_config = {
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },

      -- キーマッピング
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        -- ヘルパー関数
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- ナビゲーション: 次/前の hunk へ移動
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, { desc = "Next hunk" })

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, { desc = "Previous hunk" })

        -- アクション
        map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage hunk" })
        map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset hunk" })

        -- ビジュアルモードでの部分ステージ/リセット
        map("v", "<leader>hs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Stage selected hunk" })
        map("v", "<leader>hr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Reset selected hunk" })

        -- バッファ全体の操作
        map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Stage buffer" })
        map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Reset buffer" })

        -- ステージを取り消し
        map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "Undo stage hunk" })

        -- プレビューと情報表示
        map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview hunk" })
        map("n", "<leader>hb", function()
          gitsigns.blame_line({ full = true })
        end, { desc = "Blame line" })
        map("n", "<leader>hd", gitsigns.diffthis, { desc = "Diff this" })
        map("n", "<leader>hD", function()
          gitsigns.diffthis("~")
        end, { desc = "Diff this ~" })

        -- トグル
        map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Toggle line blame" })
        map("n", "<leader>td", gitsigns.toggle_deleted, { desc = "Toggle deleted" })

        -- テキストオブジェクト: hunk を選択
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
      end,
    })
  end,
}

