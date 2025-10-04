---@type LazyPluginSpec
local M = {
  "folke/which-key.nvim",
  event = "VeryLazy",
}

function M.config()
  -- `which-key` is the popup shown after hitting `<leader>`.  We tune the
  -- preset so it focuses on our own mappings instead of the defaults.
  local wk = require "which-key"

  wk.setup {
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = false,
        motions = false,
        text_objects = false,
        windows = false,
        nav = false,
        z = false,
        g = false,
      },
    },
    window = {
      border = "rounded",
      position = "bottom",
      padding = { 2, 2, 2, 2 },
    },
    show_help = false,
    show_keys = false,
    disable = {
      buftypes = {},
      filetypes = { "TelescopePrompt" },
    },
  }

  -- Normal-mode leader menu -------------------------------------------------
  -- Keep the specification close to the actual keymaps defined throughout the
  -- config so the UI mirrors reality.  Each entry either describes a single
  -- mapping (with `desc`) or marks an entire prefix as a group.
  ---@type table<string, any>
  local normal_mode = {
    q = { "<cmd>confirm q<CR>", desc = "Quit Neovim" },
    h = { "<cmd>nohlsearch<CR>", desc = "Clear search highlight" },
    [";"] = { "<cmd>tabnew | terminal<CR>", desc = "Terminal tab" },
    v = { "<cmd>vsplit<CR>", desc = "Vertical split" },
    w = { "<cmd>lua vim.wo.wrap = not vim.wo.wrap<CR>", desc = "Toggle wrap" },
    a = {
      name = "Tabs",
      n = { "<cmd>$tabnew<CR>", desc = "New empty tab" },
      N = { "<cmd>tabnew %<CR>", desc = "Tab from file" },
      o = { "<cmd>tabonly<CR>", desc = "Close other tabs" },
      h = { "<cmd>-tabmove<CR>", desc = "Move tab left" },
      l = { "<cmd>+tabmove<CR>", desc = "Move tab right" },
    },
    b = { name = "Buffers" },
    f = { name = "Find" },
    g = { name = "Git" },
    l = { name = "LSP" },
    p = {
      name = "Project",
      d = { "<cmd>cd %:p:h<CR>", desc = "CD to buffer dir" },
    },
    t = { name = "Test" },
    T = { name = "Treesitter" },
  }

  wk.register(normal_mode, {
    mode = "n",
    prefix = "<leader>",
  })
end

return M
