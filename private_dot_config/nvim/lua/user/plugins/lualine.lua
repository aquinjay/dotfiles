local M = {
  "nvim-lualine/lualine.nvim",
}

function M.config()
  -- Configure the statusline provided by lualine to match the rest of the UI.
  require("lualine").setup {
    options = {
      -- Remove decorative separators so the statusline stays minimal.
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      -- Keep the tree explorer from stealing focus-based highlights.
      ignore_focus = { "NvimTree" },
      -- Use the Tokyonight palette so the statusline matches the global colorscheme.
      theme = "tokyonight",
    },
    sections = {
      -- Only show git info, diagnostics, filetype, and progress for a concise layout.
      lualine_a = {},
      lualine_b = { "branch" },
      lualine_c = { "diagnostics" },
      lualine_x = { "filetype" },
      lualine_y = { "progress" },
      lualine_z = {},
    },
    -- Enable useful extensions for common tools like quickfix lists and Git status buffers.
    extensions = { "quickfix", "man", "fugitive" },
  }
end

return M
