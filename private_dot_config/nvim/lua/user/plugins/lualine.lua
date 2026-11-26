local M = {
  "nvim-lualine/lualine.nvim",
}

function M.config()
  require("lualine").setup {
    options = {
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      ignore_focus = { "neo-tree" },
      theme = "tokyonight",
    },
    sections = {
      lualine_a = {},
      lualine_b = { "branch" },
      lualine_c = { { "filename", path = 1 }, "diagnostics" },
      lualine_x = { "filetype" },
      lualine_y = { "progress" },
      lualine_z = {},
    },
    extensions = { "quickfix", "man", "neo-tree", "lazy", "mason", "trouble" },
  }
end

return M
