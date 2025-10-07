-- lua/user/plugins/neovim_project.lua
-- ============================================================================
-- 🧭 QUICK REFERENCE — neovim-project
--
-- What this does
--   • Finds projects by glob patterns you define (no LSP dependency).
--   • Saves/loads sessions per project (tabs, buffers, layouts).
--   • Exposes Telescope picker(s) to jump between projects fast.
--
-- Why use it
--   • Less custom code than rolling your own + project.nvim.
--   • Avoids deprecated LSP APIs used by some root detectors.
--
-- How to use
--   • :NeovimProjectDiscover / :NeovimProjectHistory
--   • With Telescope picker: <leader>pp (mapped below) → choose project
--   • It can auto-load your last session on startup (configurable).
--
-- Later tweaks
--   • Add/adjust `projects = { ... }` globs as your repo layout changes.
--   • Switch picker type to "fzf-lua" or "snacks" if you prefer.
-- ============================================================================

---@type LazyPluginSpec
return {
  "coffebar/neovim-project",
  lazy = false,      -- load early so sessions/working dir are ready
  priority = 100,    -- before most UI plugins restore
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- picker (choose one; Telescope fits your config)
    "nvim-telescope/telescope.nvim",
    -- session backend
    "Shatur/neovim-session-manager",
  },
  init = function()
    -- Let sessions store some plugin state if needed
    vim.opt.sessionoptions:append("globals")
  end,
  opts = {
    -- Define where your projects live (globs are supported)
    projects = {
      vim.fn.expand("~/projects/*"),
      vim.fn.expand("~/.config/*"),
      -- add more: vim.fn.expand("~/work/*"),
    },

    -- Path to store history and sessions
    datapath = vim.fn.stdpath("data"),

    -- Auto-load latest session if launching outside a project dir
    last_session_on_startup = true,
    dashboard_mode = false,

    -- Picker integration
    picker = {
      type = "telescope",         -- "telescope" | "fzf-lua" | "snacks"
      preview = {
        enabled = true,
        git_status = true,
        git_fetch = false,
        show_hidden = true,
      },
      opts = {}, -- place telescope opts here if you want
    },

    -- Session manager overrides (sane defaults)
    session_manager_opts = {
      autosave_ignore_dirs = {
        vim.fn.expand("~"),
        "/tmp",
      },
      autosave_ignore_filetypes = {
        "ccc-ui","dap-repl","dap-view","dap-view-term",
        "gitcommit","gitrebase","qf","toggleterm",
      },
    },

    -- Wait a tick after session load so LSPs attach cleanly
    filetype_autocmd_timeout = 200,
  },

  config = function(_, opts)
    require("neovim-project").setup(opts)

    -- which-key mapping to open the project picker via Telescope
    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.add({
        { "<leader>p",  group = "Project" },
        {
          "<leader>pp",
          function()
            -- uses the configured picker.type automatically
            vim.cmd("NeovimProjectDiscover history")
          end,
          desc = "Projects",
        },
      }, { mode = "n" })
    end
  end,
}
