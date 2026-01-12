-- =============================================================================
-- ターミナル設定 (toggleterm.nvim)
-- =============================================================================
-- toggleterm はフローティングターミナルやスプリットターミナルを
-- 簡単に開閉できるプラグインです。
--
-- 使い方:
--   - Ctrl+t でターミナルをトグル
--   - ターミナル内で Ctrl+t を押すとノーマルモードに戻る
--
-- 参考: https://github.com/akinsho/toggleterm.nvim
-- =============================================================================

return {
  -- プラグイン: akinsho/toggleterm.nvim
  "akinsho/toggleterm.nvim",

  -- 安定版を使用
  version = "*",

  -- 遅延読み込み: 指定したキーを押したときに読み込む
  -- これにより起動時間を短縮できる
  keys = {
    { "<leader>tt", desc = "Toggle terminal" },
    { "<leader>tl", desc = "Toggle lazygit" },
  },

  -- プラグイン読み込み後に実行される設定
  config = function()
    require("toggleterm").setup({
      -- ターミナルを開くキーマッピング
      -- Ctrl+t で開閉
      open_mapping = [[<C-t>]],

      -- ターミナルの表示方向
      -- "float"      : フローティングウィンドウ
      -- "horizontal" : 画面下部に水平分割
      -- "vertical"   : 画面右側に垂直分割
      -- "tab"        : 新しいタブで開く
      direction = "float",

      -- フローティングウィンドウの設定
      float_opts = {
        -- ウィンドウの境界線スタイル
        -- "single", "double", "shadow", "curved"
        border = "curved",

        -- ウィンドウのサイズ (0.0 - 1.0 の割合で指定)
        width = 120,
        height = 30,

        -- 背景の透明度 (0 = 不透明, 100 = 完全透明)
        -- winblend = 0,
      },

      -- ターミナルを開いたときにインサートモードに入る
      start_in_insert = true,

      -- ターミナルウィンドウに入ったときにインサートモードに入る
      insert_mappings = true,

      -- ターミナルモードでもマッピングを有効にする
      terminal_mappings = true,

      -- ターミナルを閉じるときの動作
      -- true = 閉じずに隠す (バックグラウンドで実行継続)
      persist_mode = true,

      -- シェルの指定 (nil = システムデフォルト)
      shell = vim.o.shell,
    })

    -- -------------------------------------------------------------------------
    -- カスタムターミナル: lazygit
    -- -------------------------------------------------------------------------
    -- lazygit 用の専用フローティングターミナル
    -- <leader>gg で開閉できる
    local Terminal = require("toggleterm.terminal").Terminal

    local lazygit = Terminal:new({
      cmd = "lazygit",
      dir = "git_dir",  -- Git リポジトリのルートで開く
      direction = "float",
      hidden = true,    -- :TermToggle で表示されないようにする

      -- フローティングウィンドウの設定
      float_opts = {
        border = "curved",
        width = function()
          return math.floor(vim.o.columns * 0.9)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.9)
        end,
      },

      -- lazygit を閉じたときのコールバック
      on_close = function(term)
        -- 閉じた後にバッファを更新（Git の変更を反映）
        vim.cmd("checktime")
      end,
    })

    -- キーマップ: <leader>gg で lazygit をトグル
    vim.keymap.set("n", "<leader>gg", function()
      lazygit:toggle()
    end, { desc = "Toggle lazygit" })

    -- -------------------------------------------------------------------------
    -- その他のカスタムターミナル（必要に応じて追加）
    -- -------------------------------------------------------------------------
    -- 例: htop
    -- local htop = Terminal:new({
    --   cmd = "htop",
    --   direction = "float",
    --   hidden = true,
    -- })
    -- vim.keymap.set("n", "<leader>th", function()
    --   htop:toggle()
    -- end, { desc = "Toggle htop" })
  end,
}

