-- =============================================================================
-- 外部依存ツールのチェックとインストール
-- =============================================================================
-- lazygit や ripgrep など、プラグインが依存するツールがインストールされていない場合、
-- OS に応じたパッケージマネージャーでインストールを試みます。
--
-- 対応 OS:
--   - macOS: Homebrew
--   - Debian/Ubuntu: apt-get (lazygit は GitHub Release から直接取得)
-- =============================================================================

local M = {}

-- OS タイプを判定する
local function get_os_type()
  local uname = vim.fn.system("uname -s"):gsub("\n", "")
  if uname == "Darwin" then
    return "macos"
  elseif uname == "Linux" then
    -- Debian/Ubuntu かどうかをチェック
    if vim.fn.executable("apt-get") == 1 then
      return "debian"
    end
    return "linux"
  end
  return "unknown"
end

-- ツールがインストールされていない場合、インストールを実行
local function install_if_missing(cmd, install_commands)
  if vim.fn.executable(cmd) == 0 then
    local os_type = get_os_type()
    local install_cmd = install_commands[os_type]

    if install_cmd then
      vim.notify(cmd .. " をインストール中...", vim.log.levels.INFO)
      local result = vim.fn.system(install_cmd)
      if vim.v.shell_error == 0 then
        vim.notify(cmd .. " のインストールが完了しました", vim.log.levels.INFO)
      else
        vim.notify(cmd .. " のインストールに失敗しました: " .. result, vim.log.levels.ERROR)
      end
    else
      vim.notify(
        cmd .. " がインストールされていません。手動でインストールしてください。",
        vim.log.levels.WARN
      )
    end
  end
end

-- インストールするツールの定義
-- cmd: コマンド名（実行ファイル名）
-- install: OS ごとのインストールコマンド
local tools = {
  {
    -- lazygit: TUI Git クライアント (toggleterm.lua で使用)
    cmd = "lazygit",
    install = {
      macos = "brew install lazygit",
      -- Debian/Ubuntu: 標準リポジトリにないため GitHub Release から取得
      debian = [[
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') && \
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
        tar xf /tmp/lazygit.tar.gz -C /tmp lazygit && \
        sudo install /tmp/lazygit /usr/local/bin && \
        rm /tmp/lazygit /tmp/lazygit.tar.gz
      ]],
    },
  },
  {
    -- ripgrep: 高速な grep 代替 (telescope.nvim の live_grep で使用)
    cmd = "rg",
    install = {
      macos = "brew install ripgrep",
      debian = "sudo apt-get update && sudo apt-get install -y ripgrep",
    },
  },
}

-- 依存ツールのチェックと自動インストールを実行
-- VimEnter 後に遅延実行して起動速度に影響を与えないようにする
function M.setup()
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.defer_fn(function()
        for _, tool in ipairs(tools) do
          install_if_missing(tool.cmd, tool.install)
        end
      end, 1000) -- 1秒後にチェック開始
    end,
    once = true,
  })
end

return M
