-- lua/user/plugins/telescope.lua
--
-- This file returns a Lazy.nvim plugin spec for Telescope.
-- Lazy will read this table and use it to:
--   1. install Telescope
--   2. install its dependencies/extensions
--   3. register keymaps during startup
--   4. call telescope.setup(...) with the options below
--   5. load extensions like fzf and ui-select

---@type LazyPluginSpec
return {
  -- Main Telescope plugin
  "nvim-telescope/telescope.nvim",

  -- Only load this plugin when the :Telescope command is used
  -- (or when something else requires it).
  cmd = "Telescope",

  -- Plugins Telescope depends on or can extend with
  dependencies = {
    -- Utility functions used by Telescope internally
    "nvim-lua/plenary.nvim",

    -- Native FZF sorter for faster / better fuzzy matching
    {
      "nvim-telescope/telescope-fzf-native.nvim",

      -- This extension must be compiled
      build = "make",

      -- Only try to build/load it if `make` exists on this machine
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },

    -- Extension that makes vim.ui.select(...) use Telescope UI
    -- Useful for LSP code actions, small selection menus, etc.
    "nvim-telescope/telescope-ui-select.nvim",
  },

  -- init() runs early, before the plugin is fully configured.
  -- Good place to declare keymaps / which-key groups.
  init = function()
    -- Try to load which-key safely.
    -- pcall prevents an error if which-key is not installed.
    local ok, wk = pcall(require, "which-key")
    if not ok then
      return
    end

    -- Small helper:
    -- tb("find_files", { previewer = false })
    -- returns a function that runs:
    -- require("telescope.builtin").find_files({ previewer = false })
    --
    -- This avoids repeating the same boilerplate for every keymap.
    local function tb(builtin, opts)
      return function()
        require("telescope.builtin")[builtin](opts or {})
      end
    end

    -- Register which-key groups and mappings
    wk.add({
      -- -------------------------
      -- Find group
      -- -------------------------
      { "<leader>f", group = "Find" },

      -- Find files in the current project
      -- previewer = false gives a cleaner/faster file picker
      { "<leader>ff", tb("find_files", { previewer = false }), desc = "Find files" },

      -- Live grep: search text across files with ripgrep
      { "<leader>ft", "<cmd>Telescope live_grep<cr>", desc = "Find text (ripgrep)" },

      -- Search Neovim help docs
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },

      -- Resume the last Telescope picker
      { "<leader>fl", "<cmd>Telescope resume<cr>", desc = "Last search" },

      -- Recently opened files
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },

      -- Git branches picker
      -- Lets you inspect / checkout branches
      { "<leader>fb", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },

      -- -------------------------
      -- Buffer group
      -- -------------------------
      { "<leader>b", group = "Buffers" },

      -- List open buffers
      { "<leader>bb", tb("buffers", {}), desc = "Buffers" },

      -- -------------------------
      -- Project group
      -- -------------------------
      { "<leader>p", group = "Project" },

      -- Project history from neovim-project plugin
      -- This is not a Telescope builtin; it is a separate plugin command
      {
        "<leader>pp",
        function()
          vim.cmd("NeovimProjectDiscover history")
        end,
        desc = "Projects",
      },
    }, { mode = "n" })
  end,

  -- opts() returns the configuration table that will be passed to:
  -- require("telescope").setup(opts)
  --
  -- Think of this as:
  --   defaults   = apply to most pickers
  --   pickers    = overrides for specific built-in pickers
  --   extensions = config for installed Telescope extensions
  opts = function()
    -- Telescope actions are reusable functions for picker keymaps
    local actions = require("telescope.actions")

    -- Try to load your custom icons safely
    local ok_icons, icons = pcall(require, "user.core.icons")

    -- If icons exist, use icons.ui
    -- otherwise fall back to an empty table
    local ui = ok_icons and icons.ui or {}

    -- Shared rounded border style reused in multiple places
    local rounded = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

    return {
      -- ============================================================
      -- DEFAULTS
      -- ============================================================
      -- These apply to most Telescope pickers unless overridden later
      defaults = {
        -- Icon shown before the prompt
        prompt_prefix = (ui.Telescope or "") .. " ",

        -- Marker for the currently selected entry
        selection_caret = (ui.Forward or "") .. " ",

        -- Spacing before each entry row
        entry_prefix = "   ",

        -- Start Telescope in insert mode by default
        -- Good for typing immediately
        initial_mode = "insert",

        -- Reset selection when results update
        selection_strategy = "reset",

        -- "ascending" means prompt at top, results below it
        sorting_strategy = "ascending",

        -- "smart" path display tries to shorten paths nicely
        path_display = { "smart" },

        -- Color file icons if devicons are available
        color_devicons = true,

        -- Use flex layout:
        -- Telescope will choose horizontal or vertical based on available space
        layout_strategy = "flex",

        layout_config = {
          -- Overall picker size relative to editor size
          width = 0.95,
          height = 0.90,

          -- Put prompt at top instead of bottom
          prompt_position = "top",

          -- Horizontal layout settings
          horizontal = {
            -- Preview gets 58% of width
            preview_width = 0.58,

            -- If window becomes too narrow, preview may be disabled below this width
            preview_cutoff = 80,
          },

          -- Vertical layout settings
          vertical = {
            -- Preview height when stacked vertically
            preview_height = 0.55,
            mirror = false,
          },

          -- Flex layout rule:
          -- flip into vertical layout when columns are below this threshold
          flex = {
            flip_columns = 150,
          },
        },

        -- Border chars for each Telescope pane
        borderchars = {
          prompt = rounded,
          results = rounded,
          preview = rounded,
        },

        -- Arguments passed to ripgrep for grep-based pickers like live_grep
        --
        -- Breakdown:
        --   rg                = ripgrep executable
        --   -uu               = search very aggressively, including ignored files
        --   --color=never     = no terminal colors in output
        --   --no-heading      = no file headers
        --   --with-filename   = include file name in each result
        --   --line-number     = include line number
        --   --column          = include column number
        --   --smart-case      = case-insensitive unless uppercase appears
        --   --hidden          = include hidden files
        --   --glob=!.git/     = exclude .git directory
        --
        -- Note:
        -- -uu is broad and can be noisy/slower.
        -- Keep it only if you intentionally want exhaustive search.
        vimgrep_arguments = {
          "rg",
          "-uu",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--glob=!.git/",
        },

        -- Keymaps used *inside* Telescope windows
        mappings = {
          -- Insert mode mappings inside Telescope
          i = {
            -- Cycle prompt history
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,

            -- Move selection up/down
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },

          -- Normal mode mappings inside Telescope
          n = {
            -- Close picker
            ["<esc>"] = actions.close,
            ["q"] = actions.close,

            -- Move selection like normal Vim motions
            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
          },
        },
      },

      -- ============================================================
      -- PICKERS
      -- ============================================================
      -- These are overrides for specific Telescope builtins
      pickers = {
        -- File picker
        find_files = {
          -- Disable preview pane for a faster / simpler files list
          previewer = false,

          -- Use ripgrep to list files
          -- Equivalent idea: "show me files in this project"
          find_command = {
            "rg",
            "--files",
            "--hidden",
            "--glob",
            "!.git/",
          },
        },

        -- live_grep uses defaults above; empty table means "no extra overrides"
        live_grep = {},

        -- grep_string searches for the current word / given string
        grep_string = {},

        -- Open buffers picker
        buffers = {
          -- Small compact style instead of full large picker
          theme = "dropdown",

          -- No preview pane for buffers
          previewer = false,

          -- Start in normal mode so j/k work immediately
          initial_mode = "normal",

          -- Sort recently used buffers higher
          sort_lastused = true,

          -- Extra buffer-local picker mappings
          mappings = {
            i = {
              -- In insert mode, Ctrl-d deletes selected buffer
              ["<C-d>"] = actions.delete_buffer,
            },
            n = {
              -- In normal mode, dd deletes selected buffer
              ["dd"] = actions.delete_buffer,
            },
          },
        },

        -- Colorscheme picker
        colorscheme = {
          theme = "dropdown",
          enable_preview = true,
        },

        -- LSP-related pickers:
        -- start in normal mode because many people browse these with j/k
        lsp_references = { initial_mode = "normal" },
        lsp_definitions = { initial_mode = "normal" },
        lsp_declarations = { initial_mode = "normal" },
        lsp_implementations = { initial_mode = "normal" },
      },

      -- ============================================================
      -- EXTENSIONS
      -- ============================================================
      -- Config for Telescope extensions you installed above
      extensions = {
        -- fzf-native improves fuzzy sorting performance/quality
        fzf = {
          fuzzy = true,

          -- Replace Telescope's default generic sorter
          override_generic_sorter = true,

          -- Replace Telescope's default file sorter
          override_file_sorter = true,

          -- Smart case matching
          case_mode = "smart_case",
        },

        -- ui-select changes vim.ui.select(...) to render as a Telescope dropdown
        --
        -- It styles selection popups used by other things:
        --   - LSP code actions
        --   - vim.ui.select(...)
        --   - some plugin selection menus
        ["ui-select"] = require("telescope.themes").get_dropdown({
          -- Keep popup text crisp; higher blend = more transparency
          winblend = 0,

          -- Compact centered dropdown size
          layout_config = {
            width = 0.60,
            height = 0.45,
            prompt_position = "top",
          },

          -- No preview pane for tiny choice menus
          previewer = false,

          -- Prompt at top, entries below
          sorting_strategy = "ascending",

          -- Rounded border to match rest of Telescope
          borderchars = rounded,
        }),
      },
    }
  end,

  -- config() is called after the plugin is loaded.
  -- Here we actually apply the setup and load extensions.
  config = function(_, opts)
    local telescope = require("telescope")

    -- Apply all defaults / pickers / extension configs from opts()
    telescope.setup(opts)

    -- Load extensions safely
    -- pcall prevents startup errors if one isn't available
    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "ui-select")
  end,
}
