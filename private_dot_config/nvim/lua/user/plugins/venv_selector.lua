-- lua/user/plugins/venv_selector.lua
-- Select Python virtual environments (.venv, uv, poetry, conda) and notify basedpyright.

---@type LazyPluginSpec
return {
  "linux-cultist/venv-selector.nvim",
  branch = "main",
  ft = "python",
  cmd = "VenvSelect",
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>lv", "<cmd>VenvSelect<CR>", ft = "python", desc = "Select Python venv" },
  },
  opts = {
    options = {
      notify_user_on_venv_activation = true,
    },
  },
}
