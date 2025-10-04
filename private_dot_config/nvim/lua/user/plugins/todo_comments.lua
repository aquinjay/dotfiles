---@type LazySpec
local M = {
  -- Plugin that highlights and searches TODO, HACK, WARN, etc. comments in code.
  "folke/todo-comments.nvim",
  dependencies = {
    -- Required dependency that powers asynchronous helpers for todo-comments.
    "nvim-lua/plenary.nvim",
  },
  -- Load the plugin only after Neovim finishes starting up to avoid slowing boot time.
  event = "VeryLazy",
  opts = {
    -- Controls whether signs (icons in the gutter) are enabled.
    signs = true,
    -- Determine the priority of the signs so they do not clash with diagnostics.
    sign_priority = 8,
    keywords = {
      -- Customize icon/color/alternative keywords for each type of annotation.
      FIX = {
        icon = " ",
        color = "error",
        alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
      },
      TODO = {
        icon = " ",
        color = "info",
      },
      HACK = {
        icon = " ",
        color = "warning",
      },
      WARN = {
        icon = " ",
        color = "warning",
        alt = { "WARNING", "XXX" },
      },
      PERF = {
        icon = " ",
        color = "hint",
        alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" },
      },
      NOTE = {
        icon = " ",
        color = "hint",
        alt = { "INFO" },
      },
    },
    highlight = {
      -- Highlight style for text before the keyword.
      before = "fg",
      -- Highlight style for the keyword itself.
      keyword = "wide",
      -- Highlight style for text after the keyword.
      after = "fg",
    },
    search = {
      -- Use ripgrep to locate todo comments quickly across the project.
      command = "rg",
      args = {
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
      },
    },
  },
}

return M
