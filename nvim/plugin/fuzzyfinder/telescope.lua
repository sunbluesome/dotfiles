local succeeded, telescope = pcall(require, "telescope")
if not succeeded then
    print("failed to load telescope")
    return
end

local fb_actions = require("telescope").extensions.file_browser.actions

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
    extensions = {
        file_browser = {
            theme = "dropdown",
            -- disables netrw and use telescope-file-browser in its place
            hijack_netrw = true,
        },
    },
})
