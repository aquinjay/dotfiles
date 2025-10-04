---@type LazyPluginSpec
local M = {
  "folke/which-key.nvim",
  event = "VeryLazy",
  dependencies = {
    {
      "echasnovski/mini.icons",
      opts = {},
    },
  },
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
    win = {
      border = "rounded",
      position = "bottom",
      padding = { 2, 2, 2, 2 },
    },
    triggers = {
      { "<leader>", mode = "n" },
      { "<leader>", mode = "v" },
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
  wk.add({
    { "<leader>q", "<cmd>confirm q<CR>", desc = "Quit Neovim" },
    { "<leader>h", "<cmd>nohlsearch<CR>", desc = "Clear search highlight" },
    { "<leader>;", "<cmd>tabnew | terminal<CR>", desc = "Terminal tab" },
    { "<leader>v", "<cmd>vsplit<CR>", desc = "Vertical split" },
    { "<leader>w", "<cmd>lua vim.wo.wrap = not vim.wo.wrap<CR>", desc = "Toggle wrap" },
    { "<leader>a", group = "Tabs" },
    { "<leader>an", "<cmd>$tabnew<CR>", desc = "New empty tab" },
    { "<leader>aN", "<cmd>tabnew %<CR>", desc = "Tab from file" },
    { "<leader>ao", "<cmd>tabonly<CR>", desc = "Close other tabs" },
    { "<leader>ah", "<cmd>-tabmove<CR>", desc = "Move tab left" },
    { "<leader>al", "<cmd>+tabmove<CR>", desc = "Move tab right" },
    { "<leader>b", group = "Buffers" },
    { "<leader>f", group = "Find" },
    { "<leader>g", group = "Git" },
    { "<leader>l", group = "LSP" },
    { "<leader>p", group = "Project" },
    { "<leader>pd", "<cmd>cd %:p:h<CR>", desc = "CD to buffer dir" },
    { "<leader>t", group = "Test" },
    { "<leader>T", group = "Treesitter" },
  }, { mode = "n" })
end

return M
