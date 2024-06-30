local M = {
  "TobinPalmer/Tip.nvim",
  event = "VimEnter",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "rcarriga/nvim-notify"
  },
}

function M.init()
  require("tip").setup {
      seconds = 8,
      title = "Tip!",
      -- url = "https://www.vimiscool.tech/neotip",
      url = "https://vtip.43z.one", -- Or https://vimiscool.tech/neotip
    }
    vim.notify = require("notify") --TODO: Put 'notify' in a better location. Make its own file?
  end

return M
