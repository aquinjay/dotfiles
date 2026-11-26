-- Markdown buffers (runs after Neovim's own markdown ftplugin).

-- Fold by heading via treesitter; start with everything open.
-- zc/zo/za fold a section, zM/zR close/open all. In vault notes <CR> on a
-- heading also toggles its fold (obsidian.nvim smart action).
vim.wo[0][0].foldmethod = "expr"
vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo[0][0].foldlevel = 99
vim.wo[0][0].foldtext = "" -- show the folded heading with its highlighting

-- Obsidian vaults indent with tabs at width 4 (Obsidian's default, see
-- .obsidian/app.json). Match it so lists edited here look the same there.
if require("user.core.vaults").contains(vim.api.nvim_buf_get_name(0)) then
  vim.bo.expandtab = false
  vim.bo.tabstop = 4
  vim.bo.shiftwidth = 4
  vim.bo.softtabstop = 0
end
