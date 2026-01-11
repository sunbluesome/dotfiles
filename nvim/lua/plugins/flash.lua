-- =============================================================================
-- モーションジャンプ設定 (flash.nvim)
-- =============================================================================
-- flash.nvim は EasyMotion/hop.nvim の後継となるモーションプラグインです。
-- 画面上の任意の位置にすばやくジャンプできます。
--
-- 使い方:
--   s + 文字    : その文字で始まる位置にジャンプ（ノーマルモード）
--   S           : Treesitter ベースで選択範囲を拡張
--   r + 文字    : リモートアクション（オペレーター待機モードで他の位置に対して操作）
--   f/F/t/T     : 組み込みの f/F/t/T を拡張（複数候補がある場合にラベル表示）
--   /           : 検索中にジャンプラベルを表示
--
-- 例:
--   s + a + j   : "a" で始まる位置のうち、ラベル "j" の位置にジャンプ
--   d + s + a + j : "a" で始まる位置 "j" まで削除
--
-- 参考: https://github.com/folke/flash.nvim
-- =============================================================================

return {
  "folke/flash.nvim",

  -- 遅延読み込み: 使用時に読み込む
  event = "VeryLazy",

  -- プラグイン読み込み後に実行される設定
  opts = {
    -- ラベルの設定
    labels = "asdfghjklqwertyuiopzxcvbnm",

    -- 検索設定
    search = {
      -- 検索の方向
      -- "forward", "backward", "fuzzy" (両方向)
      mode = "fuzzy",

      -- 大文字小文字を無視
      case_sensitive = false,

      -- インクリメンタル検索
      incremental = true,
    },

    -- ジャンプ設定
    jump = {
      -- ジャンプ後にジャンプリストに追加
      jumplist = true,

      -- ジャンプ先の位置
      pos = "start",  -- "start", "end", "range"

      -- オペレーターモードでの動作
      -- 自動的にジャンプ（ラベルが1つの場合）
      autojump = true,
    },

    -- ラベル設定
    label = {
      -- ラベルを大文字で表示
      uppercase = true,

      -- 現在の行のマッチを除外
      exclude = "",

      -- 最初の文字の後にラベルを表示
      after = true,

      -- 最初の文字の前にラベルを表示
      before = false,

      -- ラベルのスタイル
      style = "overlay",  -- "overlay", "inline", "eol", "right_align"

      -- 虹色のラベル
      rainbow = {
        enabled = false,
      },
    },

    -- ハイライト設定
    highlight = {
      -- 背景を暗くする
      backdrop = true,

      -- マッチのハイライトグループ
      matches = true,

      -- 優先度
      priority = 5000,

      groups = {
        match = "FlashMatch",
        current = "FlashCurrent",
        backdrop = "FlashBackdrop",
        label = "FlashLabel",
      },
    },

    -- モード別設定
    modes = {
      -- 通常の検索 (/) を拡張
      search = {
        enabled = true,
        highlight = { backdrop = false },
        jump = { history = true, register = true, nohlsearch = true },
      },

      -- 文字ジャンプ (s)
      char = {
        enabled = true,
        -- f/F/t/T を flash で拡張
        keys = { "f", "F", "t", "T", ";", "," },
        -- 複数行にまたがるジャンプを許可
        multi_line = true,
        -- ラベル表示設定
        label = { exclude = "hjkliardc" },
        -- 自動ジャンプ設定
        autohide = false,
        jump_labels = true,
      },

      -- Treesitter ベースの選択
      treesitter = {
        labels = "asdfghjklqwertyuiopzxcvbnm",
        jump = { pos = "range" },
        highlight = {
          backdrop = false,
          matches = false,
        },
      },
    },

    -- プロンプト設定
    prompt = {
      enabled = true,
      prefix = { { "⚡", "FlashPromptIcon" } },
    },
  },

  -- キーマッピング
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash jump",
    },
    {
      "S",
      mode = { "n", "x", "o" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },
    {
      "r",
      mode = "o",
      function()
        require("flash").remote()
      end,
      desc = "Remote Flash",
    },
    {
      "R",
      mode = { "o", "x" },
      function()
        require("flash").treesitter_search()
      end,
      desc = "Treesitter Search",
    },
    {
      "<c-s>",
      mode = { "c" },
      function()
        require("flash").toggle()
      end,
      desc = "Toggle Flash Search",
    },
  },
}

