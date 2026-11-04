--[[
  mason.nvim is a Neovim plugin that allows you to easily manage external editor tooling such as
  LSP servers, DAP servers, linters, and formatters through a single interface. Mason is basically
  the menu you see when a plugin gets installed now.

  mason-lspconfig.nvim closes the gap between mason.nvim and lspconfig. Its main responsibilities are to:
    * register a setup hook with lspconfig that ensures servers installed with mason.nvim are configured
    * provide extra convenience APIs such as the :LspInstall command
    * allow you to (i) automatically install, and (ii) automatically set up a predefined list of servers
    * translate between lspconfig server names and mason.nvim package names (e.g. lua_ls <-> lua-language-server)
]]
local M = {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
  },
}

function M.config()
  -- Define the language servers that should always be available. These names correspond to
  -- the identifiers used by `nvim-lspconfig`.
  local servers = {
    "lua_ls",
    "bashls",
    "jsonls",
    "basedpyright", -- Python types (pyright fork)
    "ruff", -- Python lint/format
  }

  -- mason.nvim handles installing and updating the external tooling. Modern versions expose
  -- additional quality-of-life options such as upgrading `pip` automatically and customizing
  -- the UI icons, so we take advantage of them here.
  require("mason").setup {
    ui = {
      border = "rounded",
      icons = {
        package_installed = "",
        package_pending = "",
        package_uninstalled = "",
      },
    },
    pip = {
      upgrade_pip = true,
    },
  }

  -- mason-lspconfig bridges mason.nvim with nvim-lspconfig. Ensuring the servers above are
  -- installed keeps the tooling up-to-date. Since v2 it also calls vim.lsp.enable() for every
  -- installed server (`automatic_enable`); the exclude list keeps installed-but-unwanted servers
  -- quiet. pyright is excluded so it doesn't duplicate basedpyright's diagnostics.
  require("mason-lspconfig").setup {
    ensure_installed = servers,
    automatic_enable = {
      exclude = { "pyright" },
    },
  }
end

return M
