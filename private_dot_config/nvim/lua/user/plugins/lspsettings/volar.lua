-- Volar owns .vue SFCs + template type-checking
local M = {}

M.filetypes = { "vue" }

M.settings = (function()
  local util = require "lspconfig.util"
  local cwd = vim.loop.cwd() or ""
  local tsdk = util.path.join(cwd, "node_modules", "typescript", "lib")
  -- If workspace TS is present, prefer it; else fallback to Volar’s bundled TS
  if not (vim.loop.fs_stat(tsdk) and tsdk) then
    tsdk = ""
  end
  return {
    vue = { format = { enable = true } },
    typescript = { tsdk = tsdk },
  }
end)()

return M

