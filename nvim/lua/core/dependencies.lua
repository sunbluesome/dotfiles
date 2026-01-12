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

-- OS タイプをキャッシュ (一度だけ判定)
local os_type_cache = nil

-- OS タイプを判定する (同期的だが軽量)
local function get_os_type()
  if os_type_cache then
    return os_type_cache
  end

  local uname = vim.uv.os_uname()
  if uname.sysname == "Darwin" then
    os_type_cache = "macos"
  elseif uname.sysname == "Linux" then
    -- Debian/Ubuntu かどうかをチェック
    if vim.fn.executable("apt-get") == 1 then
      os_type_cache = "debian"
    else
      os_type_cache = "linux"
    end
  else
    os_type_cache = "unknown"
  end

  return os_type_cache
end

-- 非同期でコマンドを実行する
local function async_system(cmd, on_complete)
  vim.system(
    { "sh", "-c", cmd },
    { text = true },
    vim.schedule_wrap(function(result)
      on_complete(result.code == 0, result.stdout or "", result.stderr or "")
    end)
  )
end

-- ツールがインストールされていない場合、非同期でインストールを実行
local function install_if_missing(cmd, install_commands, on_done)
  if vim.fn.executable(cmd) == 1 then
    -- 既にインストール済み
    if on_done then
      on_done()
    end
    return
  end

  local os_type = get_os_type()
  local install_cmd = install_commands[os_type]

  if not install_cmd then
    vim.notify(
      cmd .. " がインストールされていません。手動でインストールしてください。",
      vim.log.levels.WARN
    )
    if on_done then
      on_done()
    end
    return
  end

  vim.notify(cmd .. " をインストール中...", vim.log.levels.INFO)

  async_system(install_cmd, function(success, stdout, stderr)
    if success then
      vim.notify(cmd .. " のインストールが完了しました", vim.log.levels.INFO)
    else
      vim.notify(cmd .. " のインストールに失敗しました: " .. stderr, vim.log.levels.ERROR)
    end
    if on_done then
      on_done()
    end
  end)
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
  {
    -- tree-sitter-cli: nvim-treesitter のパーサーコンパイルに必要
    cmd = "tree-sitter",
    install = {
      macos = "brew install tree-sitter-cli",
      debian = "npm install -g tree-sitter-cli",
    },
  },
  {
    -- fd: 高速なファイル検索 (telescope-loam で使用)
    cmd = "fd",
    install = {
      macos = "brew install fd",
      debian = "sudo apt-get update && sudo apt-get install -y fd-find && sudo ln -sf $(which fdfind) /usr/local/bin/fd",
    },
  },
}

-- 依存ツールのチェックと自動インストールを実行
-- VimEnter 後に遅延実行して起動速度に影響を与えないようにする
function M.setup()
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.defer_fn(function()
        -- 順番にインストール（並列だと brew がロックする可能性があるため）
        local idx = 1
        local function install_next()
          if idx > #tools then
            return
          end
          local tool = tools[idx]
          idx = idx + 1
          install_if_missing(tool.cmd, tool.install, install_next)
        end
        install_next()
      end, 100) -- 100ms 後にチェック開始
    end,
    once = true,
  })
end

return M
