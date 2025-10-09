-- lua/user/plugins/telescope.lua
-- ============================================================================
-- 🧭 QUICK REFERENCE — Telescope (big layout) + neovim-project + UI-Select
--
-- What changed (from your last version)
--   • Enabled `telescope-ui-select` to style small selection popups
--     (code actions, LSP choices, vim.ui.select, etc.).
--   • The UI-Select popups use a neat dropdown: rounded, prompt on top, ~60% width.
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
    -- ✅ enable UI-Select
    "nvim-telescope/telescope-ui-select.nvim",
  },

  -- which-key bindings
  init = function()
    local ok, wk = pcall(require, "which-key")
    if not ok then return end
    local function tb(builtin, opts)
      return function() require("telescope.builtin")[builtin](opts or {}) end
    end

    wk.add({
      { "<leader>f",  group = "Find" },
      { "<leader>ff", tb("find_files", { previewer = false }),                 desc = "Find files" },
      { "<leader>ft", "<cmd>Telescope live_grep<cr>",                          desc = "Find text (ripgrep)" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",                          desc = "Help" },
      { "<leader>fl", "<cmd>Telescope resume<cr>",                             desc = "Last search" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                           desc = "Recent files" },
      { "<leader>fb", "<cmd>Telescope git_branches<cr>",                       desc = "Checkout branch" },

      { "<leader>b",  group = "Buffers" },
      { "<leader>bb", tb("buffers", { }),                                      desc = "Buffers" },

      { "<leader>p",  group = "Project" },
      {
        "<leader>pp",
        function() vim.cmd("NeovimProjectDiscover history") end,
        desc = "Projects",
      },
    }, { mode = "n" })
  end,

  opts = function()
    local actions = require "telescope.actions"
    local ok_icons, icons = pcall(require, "user.core.icons")
    local ui = ok_icons and icons.ui or {}

    -- nice rounded border chars reused by default + ui-select
    local rounded = { "─","│","─","│","╭","╮","╯","╰" }

    return {
      defaults = {
        prompt_prefix   = (ui.Telescope or "") .. " ",
        selection_caret = (ui.Forward   or "") .. " ",
        entry_prefix    = "   ",
        initial_mode    = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        path_display    = { "smart" },
        color_devicons  = true,

        layout_strategy = "flex",
        layout_config = {
          width  = 0.95,
          height = 0.90,
          prompt_position = "top",
          horizontal = { preview_width = 0.58, preview_cutoff = 80 },
          vertical   = { preview_height = 0.55, mirror = false },
          flex       = { flip_columns = 150 },
        },
        borderchars = {
          prompt  = rounded,
          results = rounded,
          preview = rounded,
        },

        vimgrep_arguments = {
          "rg","-uu","--color=never","--no-heading","--with-filename","--line-number","--column",
          "--smart-case","--hidden","--glob=!.git/",
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
        find_files = {
          previewer = false,
          find_command = { "rg", "--files", "--hidden", "--glob", "!.git/" },
        },
        live_grep   = { },
        grep_string = { },

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

        colorscheme = { theme = "dropdown", enable_preview = true },

        lsp_references      = { initial_mode = "normal" },
        lsp_definitions     = { initial_mode = "normal" },
        lsp_declarations    = { initial_mode = "normal" },
        lsp_implementations = { initial_mode = "normal" },
      },

      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter    = true,
          case_mode = "smart_case",
        },

        -- ✅ UI-Select: theme small choice menus nicely
        ["ui-select"] = function()
          local theme = require("telescope.themes").get_dropdown {
            winblend = 0,                -- keep text crisp
            layout_config = { width = 0.60, height = 0.45, prompt_position = "top" },
            previewer = false,
            sorting_strategy = "ascending",
            borderchars = rounded,
          }
          return theme
        end,
      },
    }
  end,

  config = function(_, opts)
    local telescope = require "telescope"
    telescope.setup(opts)
    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "ui-select") -- ✅ enable the extension
  end,
}

