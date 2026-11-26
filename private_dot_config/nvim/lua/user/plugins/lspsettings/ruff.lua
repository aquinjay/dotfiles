-- lua/user/plugins/lspsettings/ruff.lua
-- Ruff native LSP server settings (linting + code actions; hover is disabled
-- in lspconfig.lua so basedpyright owns K hover docs).

return {
  init_options = {
    settings = {
      logLevel = "warn",
    },
  },
}
