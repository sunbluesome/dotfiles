-- =============================================================================
-- ファジーファインダー設定 (telescope.nvim)
-- =============================================================================
-- telescope.nvim は高機能なファジーファインダーです。
-- ファイル検索、テキスト検索、Git 操作、バッファ切り替えなど様々な用途に使えます。
--
-- 使い方:
--   - <leader>ff : ファイル名で検索
--   - <leader>fg : ファイル内容で検索 (grep)
--   - <leader>fb : 開いているバッファ一覧
--   - <leader>fh : ヘルプタグ検索
--   - <leader>fr : 最近開いたファイル
--   - <leader>fd : LSP 診断情報
--   - <leader>fe : ファイルブラウザ（ファイラ）
--
-- 検索ウィンドウ内:
--   - Ctrl+j/k : 上下移動
--   - Ctrl+n/p : 履歴移動
--   - Enter    : 選択したファイルを開く
--   - Ctrl+v   : 垂直分割で開く
--   - Ctrl+x   : 水平分割で開く
--   - Ctrl+t   : 新しいタブで開く
--
-- ファイルブラウザ内:
--   - Ctrl+h   : 親ディレクトリへ移動
--   - Ctrl+e   : ディレクトリを開く
--   - Ctrl+a   : ファイル/ディレクトリ作成
--   - Ctrl+r   : リネーム
--   - Ctrl+d   : 削除
--
-- 参考: https://github.com/nvim-telescope/telescope.nvim
-- =============================================================================

return {
  -- プラグイン: nvim-telescope/telescope.nvim
  "nvim-telescope/telescope.nvim",

  -- Neovim 0.11+ では最新版を使用（0.1.8 は非対応）
  branch = "master",

  -- 依存プラグイン
  -- plenary.nvim は Lua 関数のユーティリティライブラリ
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",

    -- ファイルブラウザ拡張
    {
      "nvim-telescope/telescope-file-browser.nvim",
    },

    -- (オプション) ネイティブ FZF ソーターで検索を高速化
    -- ビルドに cmake と make が必要
    -- {
    --   "nvim-telescope/telescope-fzf-native.nvim",
    --   build = "make",
    -- },
  },

  -- 遅延読み込み: 指定したキーを押したときに読み込む
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
    -- <leader>fe は config 内で設定（カスタムマッピング付き）
    { "<leader>fe", desc = "File browser" },
  },

  -- プラグイン読み込み後に実行される設定
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      -- デフォルト設定
      defaults = {
        -- プロンプト (検索入力欄) のプレフィックス
        prompt_prefix = "> ",

        -- 選択行のプレフィックス
        selection_caret = "> ",

        -- エントリのプレフィックス
        entry_prefix = "  ",

        -- ソート戦略 (ascending = 上から, descending = 下から)
        sorting_strategy = "ascending",

        -- レイアウト設定
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",  -- プロンプトを上部に表示
            preview_width = 0.55,     -- プレビューの幅 (55%)
            results_width = 0.8,      -- 結果の幅 (80%)
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,               -- ウィンドウ全体の幅 (87%)
          height = 0.80,              -- ウィンドウ全体の高さ (80%)
          preview_cutoff = 120,       -- この幅以下でプレビューを非表示
        },

        -- 検索結果の表示形式
        path_display = { "truncate" },  -- パスを短縮表示

        -- 無視するファイルパターン
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "__pycache__",
          "%.pyc",
          ".venv",
          "venv",
          "%.egg%-info",
        },

        -- キーマッピング
        mappings = {
          -- インサートモードでのマッピング
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-c>"] = actions.close,
            ["<Esc>"] = actions.close,
          },
          -- ノーマルモードでのマッピング
          n = {
            ["q"] = actions.close,
          },
        },
      },

      -- Picker 個別の設定
      pickers = {
        -- find_files の設定
        find_files = {
          -- 隠しファイルも検索対象に含める
          hidden = true,
        },
        -- live_grep の設定
        live_grep = {
          -- 追加の ripgrep 引数
          additional_args = function()
            return { "--hidden" }  -- 隠しファイルも検索
          end,
        },
      },

      -- 拡張機能の設定
      extensions = {
        -- ファイルブラウザ
        file_browser = {
          -- レイアウト設定（プレビューを右側に表示）
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              preview_width = 0.5,  -- プレビュー幅50%
            },
            width = 0.9,
            height = 0.8,
          },
          -- ファイルブラウザ起動時にディレクトリを開く
          hijack_netrw = true,
          -- 隠しファイルを表示
          hidden = { file_browser = true, folder_browser = true },
          -- グループ化（ディレクトリを先に表示）
          grouped = true,
          -- プレビューを有効化
          previewer = true,
          -- 初期モード（insert または normal）
          initial_mode = "normal",
        },
        -- fzf-native を使う場合の設定
        -- fzf = {
        --   fuzzy = true,
        --   override_generic_sorter = true,
        --   override_file_sorter = true,
        --   case_mode = "smart_case",
        -- },
      },
    })

    -- 拡張機能の読み込み
    telescope.load_extension("file_browser")
    -- telescope.load_extension("fzf")

    -- ファイルブラウザのキーマッピング（拡張読み込み後に設定）
    local fb_actions = telescope.extensions.file_browser.actions
    vim.keymap.set("n", "<leader>fe", function()
      telescope.extensions.file_browser.file_browser({
        path = vim.fn.expand("%:p:h"),
        select_buffer = true,
        mappings = {
          ["n"] = {
            ["h"] = fb_actions.goto_parent_dir,
            ["l"] = actions.select_default,
            ["a"] = fb_actions.create,
            ["r"] = fb_actions.rename,
            ["d"] = fb_actions.remove,
            ["c"] = fb_actions.copy,
            ["m"] = fb_actions.move,
            ["."] = fb_actions.toggle_hidden,
          },
        },
      })
    end, { desc = "File browser" })
  end,
}

