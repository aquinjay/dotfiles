-- Look at builtins on github page for what languages this supports
local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

local actions = null_ls.builtins.code_actions

null_ls.setup({
	debug = false,
	sources = {

-- JavaScript
		formatting.prettier.with({extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" } }),
-- Python 
		formatting.black.with({ extra_args = { "--fast" } }),
     diagnostics.flake8, -- python linter
-- Lua
		formatting.stylua, -- add formatters and diagnositcs here

-- Shell 
    actions.shellcheck, -- Linter aka check for errors/warnings 
    diagnostics.shellcheck,
    formatting.shfmt, -- shell formatter, parser, and interpreter
	},
})
