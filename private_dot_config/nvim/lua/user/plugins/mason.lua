-- lua/user/plugins/mason.lua
-- Manages external LSP servers (mason-lspconfig v2) and CLI linters/formatters
-- (mason-tool-installer).
--
-- Notes:
--   • mason-lspconfig v2 automatically calls vim.lsp.enable() for every installed
--     server except those listed in `automatic_enable.exclude`.
--   • C/C++ uses the system /usr/bin/clangd (configured in lspconfig.lua) so it
--     matches the system compiler and standard library headers.

local M = {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
}

function M.config()
  local servers = {
    "lua_ls",
    "bashls",
    "jsonls",
    "basedpyright", -- Python types (pyright fork)
    "ruff",         -- Python lint/format
    "fish_lsp",     -- Fish shell intelligence
    "neocmakelsp",  -- CMake language server
  }

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

  require("mason-lspconfig").setup {
    ensure_installed = servers,
    automatic_enable = {
      -- pyright is excluded so it doesn't duplicate basedpyright diagnostics.
      exclude = { "pyright" },
    },
  }

  require("mason-tool-installer").setup {
    ensure_installed = {
      "shellcheck", -- Used by bashls for inline shell diagnostics
      "shfmt",      -- Bash/sh formatter (conform.nvim)
      "stylua",     -- Lua formatter (conform.nvim)
      "debugpy",    -- Python DAP debugger (nvim-dap-python)
    },
    auto_update = false,
    run_on_start = true,
  }
end

return M
