-- =============================================================================
-- 画像貼り付け設定 (img-clip.nvim)
-- =============================================================================
-- クリップボードの画像をファイルに保存し、マークダウンリンクを挿入
--
-- 依存: macOS では pngpaste が必要 (core/dependencies.lua で自動インストール)
-- 注意: DevContainer 環境ではクリップボードにアクセスできないため無効
--
-- 使い方:
--   - <leader>pi でクリップボードの画像を貼り付け
--   - 画像は {ファイル名}-001.png の形式で保存される
--
-- 参考: https://github.com/HakonHarnes/img-clip.nvim
-- =============================================================================

-- コンテナ環境では警告を表示するだけ
local in_container = vim.fn.getenv("REMOTE_CONTAINERS") ~= vim.NIL
  or vim.fn.filereadable("/.dockerenv") == 1

if in_container then
  return {
    dir = vim.fn.stdpath("config"),
    name = "markdown-image-disabled",
    ft = { "markdown" },
    config = function()
      vim.keymap.set("n", "<leader>pi", function()
        vim.notify("Image paste is not available in DevContainer", vim.log.levels.WARN)
      end, { desc = "Paste image (disabled in container)" })
    end,
  }
end

return {
  "HakonHarnes/img-clip.nvim",

  ft = { "markdown" },

  keys = {
    { "<leader>pi", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
  },

  opts = {
    default = {
      -- 画像を現在のファイルと同じディレクトリに保存
      dir_path = function()
        return vim.fn.expand("%:p:h")
      end,

      -- ファイル名パターン: {マークダウンファイル名}-001.png
      file_name = function()
        local base_name = vim.fn.expand("%:t:r")
        local dir = vim.fn.expand("%:p:h")

        local counter = 1
        while true do
          local candidate = string.format("%s-%03d", base_name, counter)
          local full_path = dir .. "/" .. candidate .. ".png"
          if vim.fn.filereadable(full_path) == 0 then
            return candidate
          end
          counter = counter + 1
        end
      end,

      extension = "png",
      relative_to_current_file = true,

      -- ファイル名の入力を求めない（自動生成）
      prompt_for_file_name = false,
    },

    filetypes = {
      markdown = {
        template = "![$LABEL]($FILE_PATH)",
        prompt_for_label = false,
        label = "image",
      },
    },
  },
}
