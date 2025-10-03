---@type LazyPluginSpec
local M = {
  "TobinPalmer/Tip.nvim",
  lazy=false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "rcarriga/nvim-notify",
  },

  -- Configuration values passed to Tip.nvim when it initializes.
  opts = {
    seconds = 9, -- Show the floating tip slightly longer than the default.
    title = "Tip!", -- Title displayed in the notification window.
    url = "https://vtip.43z.one", -- Source for the rotating tip content.
  },

  -- Runs after the plugin is loaded so we can configure it and hook into nvim-notify.
  config = function(_, opts)
    require("tip").setup(opts)

    -- Replace the default notification handler with nvim-notify so tips look nicer.
    vim.notify = require("notify")
  end,
}

return M
