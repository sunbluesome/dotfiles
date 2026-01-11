local options_global = {
    background="dark",
    termguicolors = true,  -- 24-bit True Color を有効化（モダンなカラースキームに必須）
    number = true,
    clipboard = "unnamedplus",
    mouse = "a",
    scrolloff = 10,
    visualbell = true,
    wrap = true,
    display = "lastline",
    laststatus = 3,
    backupskip = { "/tmp/*", "/private/tmp/*" },
    cursorline = true,
    foldmethod = "expr",
    foldexpr = "v:lua.vim.treesitter.foldexpr()",
    foldlevel = 99,
}

local options_file = {
    fenc = "utf-8",
    backup = false,
    swapfile = false,
    autoread = true,
    hidden = true,
    confirm = true,
}

local options_edit = {
    smartindent = false,
    pumheight = 10,
    showmatch = true,
    matchtime = 1,
    wildmode = {"longest", "full"},
    list = true,
    listchars = "tab:▸-",
    expandtab = true,
    tabstop = 4,
    shiftwidth = 4,
    autoindent = true,
    colorcolumn = "88",
}

local options_search = {
    ignorecase = true,
    smartcase = true,
    incsearch = true,
    wrapscan = true,
    hlsearch = true,
}

local options_terminal = {
    modifiable = true,
}


local options_table = {
    options_global,
    options_file,
    options_edit,
    options_search,
    options_terminal,
}

for _, options in pairs(options_table) do
    for k, v in pairs(options) do
        vim.opt[k] = v
    end
end

-- -----------------------------------------------------------------------------
-- クリップボード設定（SSH/DevContainer 環境対応）
-- -----------------------------------------------------------------------------
-- SSH 接続やコンテナ内では通常のクリップボードプロバイダーが使えないため、
-- OSC 52 エスケープシーケンスを使用してターミナル経由でクリップボードにアクセス
-- 対応ターミナル: iTerm2, Ghostty, Kitty, WezTerm など
-- -----------------------------------------------------------------------------
local function is_remote_environment()
  return vim.env.SSH_TTY ~= nil
      or vim.env.SSH_CLIENT ~= nil
      or vim.env.REMOTE_CONTAINERS ~= nil
      or vim.env.CODESPACES ~= nil
      or vim.fn.has("wsl") == 1
end

if is_remote_environment() then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end
