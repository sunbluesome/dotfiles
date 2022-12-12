local telescope = require("telescope")
local succeeded, telescope = pcall(require, "telescope")
if not suceeded then
    print("failed to load telescope")
    return
end

-- setup telesope
telescope.setup({
    defaults = {
        -- Will change the title of the preview window dynamically, where it
        -- is supported. For example, the preview window's title could show up as
        -- the full filename.
        dynamic_preview_title = true,
        -- Flex layout swaps between `horizontal` and `vertical` strategies based on
        -- the window width
        layout_strategy = 'flex',
    },
})

