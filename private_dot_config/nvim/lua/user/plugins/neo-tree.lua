-- lua/user/plugins/neo-tree.lua
-- ============================================================================
-- 🧭 QUICK REFERENCE — neo-tree (file explorer)
--
-- What this does
--   • Adds a fast sidebar file explorer with git status + diagnostics badges.
--   • Replaces netrw (opening a directory launches neo-tree instead).
--   • Follows the current buffer, so the sidebar auto-reveals the file you’re on.
--   • Closes itself if it’s the last window (no “stuck” sidebars on :q).
--
-- Keys (which-key)
--   • <leader>e  → Toggle explorer (left)
--   • <leader>E  → Reveal current file (focus the tree)
--
-- Notes
--   • Hidden files are visible; `.git/` ignored by default. Tweak below.
--   • Width defaults to 32; change in `window.width`.
--   • Works fine with Telescope + neovim-project sessions.
-- ============================================================================

---@type LazyPluginSpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",                -- lazy-load on :Neotree or our keymaps
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- optional but recommended
    "MunifTanjim/nui.nvim",
  },

  init = function()
    -- which-key bindings (don’t force-load the plugin)
    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.add({
        { "<leader>e", group = "Explorer" },
        {
          "<leader>e",
          function() vim.cmd("Neotree toggle left") end,
          desc = "Toggle file explorer",
        },
        {
          "<leader>E",
          function() vim.cmd("Neotree reveal left") end,
          desc = "Reveal current file",
        },
      }, { mode = "n" })
    end

    -- If you start Neovim with a directory: open neo-tree automatically.
    if vim.fn.argv(0) and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.cmd("Neotree left")
    end
  end,

  opts = {
    close_if_last_window = true,
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    default_component_configs = {
      indent = { padding = 1 },
      icon = {
        folder_closed = "",
        folder_open   = "",
        folder_empty  = "󰜌",
      },
      modified = { symbol = "●" },
      git_status = {
        symbols = {
          added    = "A",
          modified = "M",
          deleted  = "D",
          renamed  = "R",
          untracked= "U",
          ignored  = "◌",
          unstaged = "",
          staged   = "S",
          conflict = "",
        },
      },
      diagnostics = {
        symbols = { hint = "", info = "", warn = "", error = "" },
      },
    },

    window = {
      position = "left",
      width = 32,
      mappings = {
        ["<space>"] = "toggle_node",
        ["h"] = "close_node",
        ["l"] = "open",
        ["<CR>"] = "open",
        ["q"] = "close_window",
        ["<C-r>"] = "refresh",
        ["a"] = { "add", config = { show_path = "relative" } },
        ["d"] = "delete",
        ["r"] = "rename",
        ["y"] = "copy_to_clipboard",
        ["p"] = "paste_from_clipboard",
      },
    },

    filesystem = {
      hijack_netrw_behavior = "open_default",
      follow_current_file = { enabled = true, leave_dirs_open = false },
      use_libuv_file_watcher = true,
      filtered_items = {
        visible = true,         -- show filtered items but dim them
        hide_dotfiles = false,  -- show dotfiles by default (you like hidden files)
        hide_gitignored = true, -- but keep gitignored hidden
        hide_by_name = { "node_modules" },
      },
    },

    buffers = {
      follow_current_file = { enabled = true },
      group_empty_dirs = true,
      show_unloaded = true,
    },

    git_status = {
      window = { position = "float" },
    },

    source_selector = {
      winbar = false,          -- set to true if you want a tab-like bar above the tree
      statusline = false,
    },
  },

  config = function(_, opts)
    -- Try to pull your icon set; fall back silently if missing.
    local ok_icons, icons = pcall(require, "user.core.icons")
    if ok_icons and icons.ui then
      opts.default_component_configs.icon.folder_closed = icons.ui.Folder or opts.default_component_configs.icon.folder_closed
      opts.default_component_configs.icon.folder_open   = icons.ui.FolderOpen or opts.default_component_configs.icon.folder_open
    end

    require("neo-tree").setup(opts)

    -- Optional: close neo-tree when you open a file in it (single-click workflow)
    -- vim.api.nvim_create_autocmd("BufEnter", {
    --   pattern = "*",
    --   callback = function()
    --     if vim.bo.filetype ~= "neo-tree" and vim.fn.winnr("$") > 1 then
    --       pcall(vim.cmd, "Neotree close")
    --     end
    --   end,
    -- })
  end,
}
