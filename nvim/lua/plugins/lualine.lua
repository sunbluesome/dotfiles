-- =============================================================================
-- ステータスライン設定 (lualine.nvim)
-- =============================================================================
-- lualine は高速で高機能なステータスラインプラグインです。
-- モード、ファイル名、Git ブランチ、診断情報などを表示します。
--
-- 参考: https://github.com/nvim-lualine/lualine.nvim
-- =============================================================================

return {
  -- プラグイン: nvim-lualine/lualine.nvim
  "nvim-lualine/lualine.nvim",

  -- アイコン表示のための依存プラグイン
  -- ファイルタイプアイコンなどを表示するために必要
  dependencies = { "nvim-tree/nvim-web-devicons" },

  -- 遅延読み込み: 起動後少し遅れて読み込む
  -- ステータスラインは即座に必要ではないので VeryLazy で読み込み
  event = "VeryLazy",

  -- プラグイン読み込み後に実行される設定
  config = function()
    require("lualine").setup({
      -- 基本オプション
      options = {
        -- カラースキームに合わせたテーマを使用
        -- iceberg を使用している場合は "iceberg_dark" を指定
        -- solarized の場合は "solarized_dark" に変更
        theme = "iceberg_dark",

        -- セクション間の区切り文字
        -- 丸みを帯びた形状
        section_separators = { left = "", right = "" },

        -- コンポーネント間の区切り文字
        component_separators = { left = "", right = "" },

        -- 非アクティブウィンドウでもステータスラインを表示
        -- (Neovim 0.7+ では laststatus=3 でグローバルステータスライン)
        globalstatus = true,
      },

      -- 左側のセクション (A, B, C)
      sections = {
        -- セクション A: モード表示 (NORMAL, INSERT, VISUAL など)
        lualine_a = { "mode" },

        -- セクション B: Git ブランチと差分情報
        lualine_b = {
          "branch",    -- 現在の Git ブランチ
          "diff",      -- 追加/変更/削除の行数
          "diagnostics", -- LSP 診断情報 (エラー/警告数)
        },

        -- セクション C: ファイル名
        lualine_c = {
          {
            "filename",
            -- ファイルパスの表示形式
            -- 0 = ファイル名のみ
            -- 1 = 相対パス
            -- 2 = 絶対パス
            path = 1,
          },
        },

        -- セクション X: ファイル情報
        lualine_x = {
          "encoding",   -- ファイルエンコーディング (utf-8 など)
          "fileformat", -- ファイル形式 (unix/dos/mac)
          "filetype",   -- ファイルタイプ (python, lua など)
        },

        -- セクション Y: 進捗表示
        lualine_y = { "progress" },  -- ファイル内の現在位置 (%)

        -- セクション Z: カーソル位置
        lualine_z = { "location" },  -- 行:列
      },

      -- 非アクティブウィンドウのセクション設定
      -- グローバルステータスラインの場合は使用されない
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    })
  end,
}

