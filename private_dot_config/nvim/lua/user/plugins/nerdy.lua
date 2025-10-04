---@type LazySpec
local M = {
  -- Plugin providing Telescope picker to browse Nerd Font icons.
  "2KAbhishek/nerdy.nvim",
  dependencies = {
    -- Fancy UI enhancements for picker prompts.
    "stevearc/dressing.nvim",
    -- Nerdy piggybacks on Telescope for its picker UI.
    "nvim-telescope/telescope.nvim",
  },
  -- Load plugin only for the :Nerdy command or defined keymaps.
  cmd = "Nerdy",
  keys = {
    {
      "<leader>fn",
      "<cmd>Nerdy<CR>",
      desc = "Find Nerd Font icon",
    },
  },
  config = function()
    -- Fall back to JetBrainsMono if no user preference is provided.
    local preferred_font = vim.g.preferred_nerd_font or vim.env.NERD_FONT or "JetBrainsMono Nerd Font"

    require("nerdy").setup {
      -- Limit picker entries to a single Nerd Font family for consistent glyphs.
      nerd_font = preferred_font,
    }
  end,
}

return M
