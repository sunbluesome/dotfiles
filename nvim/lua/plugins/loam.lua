-- =============================================================================
-- telescope-loam: Zettelkasten workflow plugin (local development)
-- =============================================================================
-- This configuration loads the plugin from a local directory for development.
-- Once the plugin is ready for release, change `dir` to the GitHub repository.
--
-- Keybindings:
--   <leader>zn - Find notes
--   <leader>zg - Grep notes
--   <leader>zc - Create new note
--   <leader>zb - Show backlinks
--   <leader>zi - Browse indexes
--   <leader>zj - Browse journal
--   <leader>zt - Filter by tags
--   <leader>zT - Filter by type
--   <leader>zf - Follow link under cursor
--   <leader>zd - Open today's journal
-- =============================================================================

return {
  dir = "~/Projects/telescope-loam",
  name = "telescope-loam",
  dev = true,
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },

  -- Load when these keys are pressed or commands are used
  keys = {
    { "<leader>zn", "<cmd>Telescope loam notes<cr>", desc = "Loam: Find notes" },
    { "<leader>zg", "<cmd>Telescope loam grep<cr>", desc = "Loam: Grep notes" },
    { "<leader>zc", "<cmd>Telescope loam new<cr>", desc = "Loam: Create note" },
    { "<leader>zb", "<cmd>Telescope loam backlinks<cr>", desc = "Loam: Backlinks" },
    { "<leader>zi", "<cmd>Telescope loam indexes<cr>", desc = "Loam: Indexes" },
    { "<leader>zj", "<cmd>Telescope loam journal<cr>", desc = "Loam: Journal" },
    { "<leader>zt", "<cmd>Telescope loam tags<cr>", desc = "Loam: Filter by tags" },
    { "<leader>zT", "<cmd>Telescope loam types<cr>", desc = "Loam: Filter by type" },
    { "<leader>zf", "<cmd>LoamFollow<cr>", desc = "Loam: Follow link" },
    { "<leader>zd", "<cmd>LoamToday<cr>", desc = "Loam: Today's journal" },
  },

  cmd = {
    "Loam",
    "LoamNew",
    "LoamGrep",
    "LoamBacklinks",
    "LoamIndexes",
    "LoamJournal",
    "LoamTags",
    "LoamTypes",
    "LoamFollow",
    "LoamToday",
  },

  -- Plugin configuration
  opts = {
    -- Path to your Zettelkasten notes directory
    notes_path = vim.fn.expand("~/Projects/personal-knowledge"),

    -- Subdirectory structure (relative to notes_path)
    directories = {
      permanent = "Notes/Permanent",
      fleeting = "Notes/Fleeting",
      literature = "Notes/Literature",
      project = "Notes/Project",
      index = "Notes/Permanent",
      structure = "Notes/Permanent",
      journal = "journal",
    },

    -- Template directory (relative to notes_path)
    templates_path = ".foam/templates",

    -- File extension for notes
    extension = ".md",

    -- Link format preference: "wiki" for [[UUID|title]] or "markdown" for [title](UUID.md)
    default_link_format = "wiki",

    -- Picker settings
    picker = {
      show_icons = true,
      show_tags = true,
      initial_mode = "insert",
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = {
          preview_width = 0.5,
        },
        width = 0.9,
        height = 0.8,
      },
    },
  },

  config = function(_, opts)
    -- Setup loam with options first
    require("loam").setup(opts)
    -- Then load the telescope extension
    require("telescope").load_extension("loam")
  end,
}
