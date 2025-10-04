local M = {
  "lukas-reineke/indent-blankline.nvim",
  event = "VeryLazy",
  commit = "9637670896b68805430e2f72cf5d16be5b97a22a",
}

function M.config()
  -- Grab the shared icon set so the guides match the rest of the UI.
  local icons = require "user.core.icons"
  -- Access the plugin to provide custom setup options.
  local indent_blankline = require "indent_blankline"

  indent_blankline.setup {
    -- Disable guides for temporary or helper buffers where they add noise.
    buftype_exclude = { "terminal", "nofile" },
    filetype_exclude = {
      "help",
      "startify",
      "dashboard",
      "lazy",
      "neogitstatus",
      "NvimTree",
      "Trouble",
      "text",
    },
    -- Use a thin vertical line for both regular and context guides.
    char = icons.ui.LineMiddle,
    context_char = icons.ui.LineMiddle,
    -- Hide visual clutter while still keeping the first indent visible.
    show_trailing_blankline_indent = false,
    show_first_indent_level = true,
    -- Rely on Treesitter to detect scope boundaries and highlight them.
    use_treesitter = true,
    show_current_context = true,
    show_current_context_start = true,
  }

  -- Allow quickly toggling guides when the extra detail is distracting.
  vim.keymap.set("n", "<leader>ui", function()
    vim.cmd "IndentBlanklineToggle"
  end, { desc = "Toggle indent guides" })
end

return M
