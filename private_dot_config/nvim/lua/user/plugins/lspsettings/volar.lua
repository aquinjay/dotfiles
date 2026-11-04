-- Volar owns .vue SFCs + template type-checking
local M = {}

M.filetypes = { "vue" }

M.settings = (function()
  local tsdk = vim.fs.joinpath(vim.uv.cwd() or "", "node_modules", "typescript", "lib")
  -- If workspace TS is present, prefer it; else fallback to Volar’s bundled TS
  if not vim.uv.fs_stat(tsdk) then
    tsdk = ""
  end
  return {
    vue = { format = { enable = true } },
    typescript = { tsdk = tsdk },
  }
end)()

return M
