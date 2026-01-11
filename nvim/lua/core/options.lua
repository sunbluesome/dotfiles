local options_global = {
    background="dark",
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
    foldmethod = "syntax",
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
