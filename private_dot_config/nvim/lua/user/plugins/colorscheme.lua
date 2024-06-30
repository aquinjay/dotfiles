local M = {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {style="night"},
}

-- Note this adds another key value pair to the M table: config = function() vim.....
function M.config()
  vim.cmd.colorscheme "tokyonight"
end

return M
