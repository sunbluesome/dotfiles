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
  keys = {
    { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    { "<leader>gg", desc = "Toggle lazygit" },
  },

  config = function()
    require("toggleterm").setup({
      open_mapping = [[<C-t>]],
      direction = "float",
      float_opts = {
        border = "curved",
        width = 120,
        height = 30,
      },
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_mode = true,
      shell = vim.o.shell,
    })

    -- lazygit 用ターミナル
    local lazygit = require("toggleterm.terminal").Terminal:new({
      cmd = "lazygit",
      dir = "git_dir",
      direction = "float",
      hidden = true,
      float_opts = {
        border = "curved",
        width = function()
          return math.floor(vim.o.columns * 0.9)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.9)
        end,
      },
      on_close = function()
        vim.cmd("checktime")
      end,
    })

    vim.keymap.set("n", "<leader>gg", function()
      lazygit:toggle()
    end, { desc = "Toggle lazygit" })
  end,
}

