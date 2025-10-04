--NOTE: mason.nvim is a Neovim plugin that allows you to easily manage external editor tooling such as LSP servers, DAP servers, linters, and formatters through a single interface.
-- Mason is basically the menu you see when a plugin gets installed now.

--NOTE:mason-lspconfig.nvim closes some gaps that exist between mason.nvim and lspconfig. Its main responsibilities are to:
--register a setup hook with lspconfig that ensures servers installed with mason.nvim are set up with the necessary configuration
--provide extra convenience APIs such as the :LspInstall command
--allow you to (i) automatically install, and (ii) automatically set up a predefined list of servers
--translate between lspconfig server names and mason.nvim package names (e.g. lua_ls <-> lua-language-server)
local M = {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
  },
}


function M.config()
  local servers = {
    "lua_ls",
    "pyright",
    "bashls",
    "jsonls",
  }

  require("mason").setup {
    ui = {
      border = "rounded",
    },
  }

  require("mason-lspconfig").setup {
    ensure_installed = servers,
  }
end

return M
