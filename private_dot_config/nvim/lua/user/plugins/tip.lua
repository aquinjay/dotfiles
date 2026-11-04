---@type LazyPluginSpec[]
return {
  -- nvim-notify: nicer floating notifications for every vim.notify() call.
  -- Kept as its own spec so it stays active while Tip.nvim is disabled.
  {
    "rcarriga/nvim-notify",
    lazy = false,
    config = function()
      -- Replace the default notification handler with nvim-notify so messages look nicer.
      vim.notify = require("notify")
    end,
  },

  {
    "TobinPalmer/Tip.nvim",
    -- Disabled 2026-11-03: vtip.43z.one returns 502 Bad Gateway, so the raw HTML
    -- error page was shown as the startup tip. Flip back to true once it's up
    -- (check: curl -s -o /dev/null -w '%{http_code}' https://vtip.43z.one).
    enabled = false,
    lazy = false,
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
  },
}
