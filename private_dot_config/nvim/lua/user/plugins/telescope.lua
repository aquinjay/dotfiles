-- lua/user/plugins/telescope.lua
-- ============================================================================
-- 🧭 QUICK REFERENCE — Telescope (finders) + neovim-project (projects)
--
-- What this file does
--   • Loads Telescope lazily and configures common pickers (files, grep, buffers…).
--   • Uses FZF-native for fast fuzzy matching (if `make` is available).
--   • Maps keys under your existing which-key groups:
--       <leader>ff  files   | <leader>ft  live grep
--       <leader>bb  buffers | <leader>fr  recent files
--       <leader>fb  branches| <leader>pp  projects (via neovim-project)
--
-- Project picker
--   • We call `:NeovimProjectDiscover history` (from coffebar/neovim-project).
--     This avoids any LSP-root hacks and the Neovim 0.10 deprecation warnings.
--
-- Extend later
--   • Add more pickers: see `init()` → `tb("builtin_name", opts)`.
--   • Add extensions: load in `config()` with pcall.
--
-- Requires
--   • `coffebar/neovim-project` installed and configured in its own spec.
--     (We don’t declare it here as a dependency to keep responsibilities split.)
-- ============================================================================

---@type LazyPluginSpec
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function() return vim.fn.executable("make") == 1 end,
    },
  },

  -- which-key bindings without force-loading Telescope
  init = function()
    local ok, wk = pcall(require, "which-key")
    if not ok then return end

    local function tb(builtin, opts)
      return function()
        require("telescope.builtin")[builtin](opts or {})
      end
    end

    wk.add({
      -- Find group
      { "<leader>f",  group = "Find" },
      { "<leader>ff", tb("find_files", { theme = "dropdown", previewer = false }), desc = "Find files" },
      { "<leader>ft", "<cmd>Telescope live_grep<cr>",                                 desc = "Find text (ripgrep)" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",                                 desc = "Help" },
      { "<leader>fl", "<cmd>Telescope resume<cr>",                                    desc = "Last search" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                                  desc = "Recent files" },
      { "<leader>fb", "<cmd>Telescope git_branches<cr>",                              desc = "Checkout branch" },

      -- Buffers
      { "<leader>b",  group = "Buffers" },
      { "<leader>bb", tb("buffers", { theme = "dropdown", previewer = false }),       desc = "Buffers" },

      -- Projects (neovim-project)
      { "<leader>p",  group = "Project" },
      {
        "<leader>pp",
        function()
          -- Opens the neovim-project Telescope/fzf/snacks picker per its config
          vim.cmd("NeovimProjectDiscover history")
        end,
        desc = "Projects",
      },
      -- keep your existing <leader>pd (“CD to buffer dir”) from which-key.lua
    }, { mode = "n" })
  end,

  opts = function()
    local actions = require "telescope.actions"
    local ok_icons, icons = pcall(require, "user.core.icons")
    local ui = ok_icons and icons.ui or {}

    return {
      defaults = {
        prompt_prefix   = (ui.Telescope or "") .. " ",
        selection_caret = (ui.Forward   or "") .. " ",
        entry_prefix    = "   ",
        initial_mode    = "insert",
        selection_strategy = "reset",
        path_display    = { "smart" },
        color_devicons  = true,

        vimgrep_arguments = {
          "rg", "--color=never", "--no-heading", "--with-filename",
          "--line-number", "--column", "--smart-case",
          "--hidden", "--glob=!.git/",
        },

        mappings = {
          i = {
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
          n = {
            ["<esc>"] = actions.close,
            ["j"]     = actions.move_selection_next,
            ["k"]     = actions.move_selection_previous,
            ["q"]     = actions.close,
          },
        },
      },

      pickers = {
        live_grep   = { theme = "dropdown" },
        grep_string = { theme = "dropdown" },

        find_files  = {
          theme = "dropdown",
          previewer = false,
          find_command = { "rg", "--files", "--hidden", "--glob", "!.git/" },
        },

        buffers = {
          theme = "dropdown",
          previewer = false,
          initial_mode = "normal",
          sort_lastused = true,
          mappings = {
            i = { ["<C-d>"] = actions.delete_buffer },
            n = { ["dd"]    = actions.delete_buffer },
          },
        },

        colorscheme = { enable_preview = true },

        -- LSP pickers: dropdown + normal-mode for big lists
        lsp_references      = { theme = "dropdown", initial_mode = "normal" },
        lsp_definitions     = { theme = "dropdown", initial_mode = "normal" },
        lsp_declarations    = { theme = "dropdown", initial_mode = "normal" },
        lsp_implementations = { theme = "dropdown", initial_mode = "normal" },
      },

      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter    = true,
          case_mode = "smart_case",
        },
      },
    }
  end,

  config = function(_, opts)
    local telescope = require "telescope"
    telescope.setup(opts)
    pcall(telescope.load_extension, "fzf")
    -- No 'projects' extension here; neovim-project provides its own commands/picker.
  end,
}
