-- Configure UI file-type icons provided by nvim-web-devicons.
-- The plugin is lazy-loaded on the VeryLazy event to avoid slowing down startup.
local M = {
  "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
}

function M.config()
  -- Use the default setup for devicons. This provides icons for filetypes in
  -- statuslines, completion menus, and other UI components that support them.
  require('nvim-web-devicons').setup{}
end

return M
