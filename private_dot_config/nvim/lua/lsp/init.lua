local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

require "lsp.mason" -- lsp is at the same level as core
require("lsp.handlers").setup() -- 
require "lsp.null-ls"
