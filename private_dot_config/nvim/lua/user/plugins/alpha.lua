local M = {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
}

function M.config()
  local alpha = require "alpha"
  local dashboard = require("alpha.themes.dashboard")

  dashboard.section.header.val = {
    "                                                    ",
    " ███╗   ██╗██╗   ██╗██╗███╗   ███╗                   ",
    " ████╗  ██║██║   ██║██║████╗ ████║                   ",
    " ██╔██╗ ██║██║   ██║██║██╔████╔██║                   ",
    " ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║                   ",
    " ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║                   ",
    " ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝                   ",
    "                                                    ",
  }

  dashboard.section.buttons.val = {
    dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
    dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
    dashboard.button("p", "  Projects", ":NeovimProjectDiscover history<CR>"),
    dashboard.button("c", "  Config", ":Telescope find_files cwd=~/.config/nvim<CR>"),
    dashboard.button("q", "  Quit", ":qa<CR>"),
  }

  dashboard.section.footer.val = {
    "Tokyonight + Lazy.nvim",
  }

  dashboard.opts.opts.noautocmd = true
  alpha.setup(dashboard.opts)

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "alpha",
    callback = function()
      vim.opt_local.foldenable = false
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.signcolumn = "no"
    end,
  })
end

return M
