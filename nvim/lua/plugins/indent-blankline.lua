-- =============================================================================
-- インデントガイド設定 (indent-blankline.nvim)
-- =============================================================================
-- indent-blankline.nvim はインデントレベルを視覚的に表示するプラグインです。
-- コードの構造を把握しやすくなり、特にネストの深いコードで効果を発揮します。
--
-- 表示:
--   - 縦線でインデントレベルを表示
--   - 現在のスコープをハイライト
--
-- 参考: https://github.com/lukas-reineke/indent-blankline.nvim
-- =============================================================================

return {
  -- プラグイン: lukas-reineke/indent-blankline.nvim
  "lukas-reineke/indent-blankline.nvim",

  -- プラグインのメインモジュール名
  -- require("ibl") で設定する
  main = "ibl",

  -- 遅延読み込み: ファイルを開いたときに読み込む
  event = { "BufReadPost", "BufNewFile" },

  -- プラグイン読み込み後に実行される設定
  config = function()
    require("ibl").setup({
      -- インデントガイドの設定
      indent = {
        -- インデントを示す文字
        -- │ (細い縦線) や ┊ (点線) などが使える
        char = "│",

        -- タブ文字を示す文字
        tab_char = "│",

        -- ハイライトグループ
        -- デフォルトの薄い色を使用
        highlight = "IblIndent",

        -- スマートインデント (空行でも表示)
        -- smart_indent_cap = true,
      },

      -- 現在のスコープ (カーソル位置のブロック) のハイライト設定
      scope = {
        -- スコープのハイライトを有効化
        enabled = true,

        -- スコープを示す文字 (インデントと同じ)
        char = "│",

        -- スコープの開始/終了を示す下線を表示
        show_start = true,
        show_end = false,

        -- ハイライトグループ
        highlight = "IblScope",

        -- treesitter を使用してスコープを検出
        -- より正確なスコープ検出が可能
        include = {
          node_type = {
            -- スコープとして認識するノードタイプ
            ["*"] = {
              "class",
              "function",
              "method",
              "for",
              "while",
              "if",
              "with",
              "try",
              "except",
              "match",
            },
          },
        },
      },

      -- 除外設定
      exclude = {
        -- 除外するファイルタイプ
        filetypes = {
          "help",
          "dashboard",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "oil",
          "NvimTree",
          "",  -- 無名バッファ
        },
        -- 除外するバッファタイプ
        buftypes = {
          "terminal",
          "nofile",
          "quickfix",
          "prompt",
        },
      },

      -- 空白行にもインデントガイドを表示
      whitespace = {
        -- 空白のハイライト
        highlight = "IblWhitespace",
        -- 末尾の空白を削除して表示
        remove_blankline_trail = true,
      },
    })

    -- カスタムハイライトグループの設定 (オプション)
    -- カラースキームによっては調整が必要な場合がある
    -- vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3e4451" })
    -- vim.api.nvim_set_hl(0, "IblScope", { fg = "#61afef" })
  end,
}

