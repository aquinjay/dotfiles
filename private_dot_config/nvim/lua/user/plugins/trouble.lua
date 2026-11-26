-- lua/user/plugins/trouble.lua
-- Structured drawer for workspace/buffer diagnostics, LSP symbols, references, and quickfix.

---@type LazyPluginSpec
return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Workspace diagnostics" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics" },
    { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Document symbols" },
    { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP defs / refs" },
    { "<leader>xL", "<cmd>Trouble loclist toggle<CR>", desc = "Location list" },
    { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix list" },
  },
  opts = {
    focus = true,
  },
}
