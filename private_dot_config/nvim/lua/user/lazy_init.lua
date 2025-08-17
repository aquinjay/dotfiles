-- Initizialize the lazy plugin. Either find the path to lazy or install it in the specified location
local lazypath = vim.fn.stdpath "data"  .. "/lazy/lazy.nvim" -- Gets the data direcotry path (usually .local/share/nvim) and concatenates another path to it 
if not vim.loop.fs_stat(lazypath) then -- if the above does not exit, then install lazy.nvim
  vim.fn.system({ -- executes shell commands
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local lazy_helper = require "user.core.lazy_helper"

-- Have lazy find the plugins file and require all the plugins listed
require("lazy").setup({
  --"folke/tokyonight.nvim",
  spec = lazy_helper.plugin_spec,
  install = {
    colorscheme = {"tokyonight"}
  },
  ui = {
    border = "rounded",
  },
  change_detection = {
    enabled = true,
    notify = true,
  },
})
