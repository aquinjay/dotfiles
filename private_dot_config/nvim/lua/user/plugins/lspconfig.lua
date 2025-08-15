local M = {
  {
    "neovim/nvim-lspconfig",
    event={"BufReadPre","BufNewFile"},
    dependencies={
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files 
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found 
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },
    config=function()
      require"lspconfig".lua_ls.setup{}
  -- vim.lsp.enable('lua_ls')
    end,
  }
}

return M
