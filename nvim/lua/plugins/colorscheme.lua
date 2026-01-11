-- =============================================================================
-- カラースキーム設定 (tokyonight.nvim)
-- =============================================================================
-- Tokyo Night は人気のモダンなカラースキームです。
-- Treesitter、LSP セマンティックトークンに完全対応しています。
--
-- 参考: https://github.com/folke/tokyonight.nvim
-- =============================================================================

return {
  -- プラグイン: folke/tokyonight.nvim
  "folke/tokyonight.nvim",

  -- カラースキームは起動時に必ず必要なので、遅延読み込みしない
  lazy = false,

  -- 他のプラグインより先に読み込む（最高優先度）
  priority = 1000,

  -- プラグイン読み込み後に実行される設定
  config = function()
    require("tokyonight").setup({
      style = "night",  -- "storm", "moon", "night", "day" から選択
      transparent = false,
      terminal_colors = true,

      -- ハイライトのカスタマイズ
      on_highlights = function(hl, c)
        -- -----------------------------------------------------------------
        -- LSP セマンティックトークンのハイライト強化
        -- -----------------------------------------------------------------
        -- モジュール名 (from xxx import ...)
        hl["@lsp.type.namespace"] = { fg = c.cyan }
        hl["@lsp.type.namespace.python"] = { fg = c.cyan }

        -- クラス名
        hl["@lsp.type.class"] = { fg = c.yellow }
        hl["@lsp.type.class.python"] = { fg = c.yellow }

        -- 関数呼び出し
        hl["@lsp.type.function"] = { fg = c.blue }
        hl["@lsp.type.function.python"] = { fg = c.blue }
        hl["@lsp.type.method"] = { fg = c.blue }
        hl["@lsp.type.method.python"] = { fg = c.blue }

        -- 変数・パラメータ
        hl["@lsp.type.parameter"] = { fg = c.orange, italic = true }
        hl["@lsp.type.parameter.python"] = { fg = c.orange, italic = true }
        hl["@lsp.type.variable"] = { fg = c.fg }
        hl["@lsp.type.variable.python"] = { fg = c.fg }

        -- プロパティ
        hl["@lsp.type.property"] = { fg = c.green1 }
        hl["@lsp.type.property.python"] = { fg = c.green1 }

        -- デコレータ
        hl["@lsp.type.decorator"] = { fg = c.yellow }
        hl["@lsp.type.decorator.python"] = { fg = c.yellow }

        -- -----------------------------------------------------------------
        -- Treesitter ハイライトの補完
        -- -----------------------------------------------------------------
        -- 関数呼び出し時の関数名
        hl["@function.call"] = { fg = c.blue }
        hl["@function.call.python"] = { fg = c.blue }
        hl["@method.call"] = { fg = c.blue }
        hl["@method.call.python"] = { fg = c.blue }

        -- モジュール (import 文)
        hl["@module"] = { fg = c.cyan }
        hl["@module.python"] = { fg = c.cyan }

        -- 型アノテーション
        hl["@type"] = { fg = c.yellow }
        hl["@type.python"] = { fg = c.yellow }
      end,
    })

    -- カラースキームを適用
    vim.cmd.colorscheme("tokyonight")
  end,
}

-- =============================================================================
-- Solarized を使用する場合（代替設定）
-- =============================================================================
-- 上記の return ブロックをコメントアウトし、以下を有効にしてください：
--
-- return {
--   "maxmx03/solarized.nvim",
--   lazy = false,
--   priority = 1000,
--   config = function()
--     require("solarized").setup({
--       -- variant = "autumn",  -- "spring", "summer", "autumn", "winter"
--     })
--     vim.cmd.colorscheme("solarized")
--   end,
-- }
-- =============================================================================

