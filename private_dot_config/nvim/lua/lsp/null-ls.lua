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

-- local completion = null_ls.builtins.completion

-- local js_source = {}
-- js_source = actions.refactoring.with({filetypes = {"javascript"}})
-- js_source = diagnostics.jshint
-- js_source = formatting.deno_fmt -- No Vue
-- js_source = formatting.prettierd.with({extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" }, filetypes = {"vue", "css"}})
-- --
-- null_ls.register({
--   name = "JavaScript",
--   filetypes = {"javascript", "css", "html", "vue"},
--   sources = js_source
-- })
--
-- local shell_source = {}
-- shell_source = actions.shellcheck -- Linter aka check for errors/warnings 
-- shell_source = diagnostics.shellcheck
-- --shell_source = formatting.shfmt -- shell formatter, parser, and interpreter
--
-- null_ls.register({
--   name = "Shell",
--   filetypes = {"sh"},
--   sources = shell_source
-- })
--
-- local cpp_source = {}
-- cpp_source.method = null_ls.methods.cppcheck -- Linter aka check for errors/warnings 
-- cpp_source.method = null_ls.methods.cpplint
-- --cpp_source = formatting.clang_format -- shell formatter, parser, and interpreter
--
-- null_ls.register({
--   sources = cpp_source
-- })



-- null_ls.setup({
--   debug = true,
--   on_init = function (new_client,_)
--     new_client.offset_encoding = 'utf-32'
--   end,

null_ls.setup({
	debug = false,
	sources = {
    -- All filetypes 
    --completion.luasnip,

-- JavaScript and Vue
    actions.refactoring.with({filetypes = {"javascript", "python"}}),
    diagnostics.jshint,
    --formatting.eslint_d.with({filetypes = {"vue"} }), -- Vue only
		formatting.prettierd.with({extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" }}),
-- Python 
		formatting.black.with({ extra_args = { "--fast" } }),
    diagnostics.flake8, -- python linter
-- Lua
		formatting.stylua, -- add formatters and diagnositcs here

-- Shell 
    actions.shellcheck, -- Linter aka check for errors/warnings 
    diagnostics.shellcheck,
    formatting.shfmt, -- shell formatter, parser, and interpreter

-- C++
     diagnostics.cppcheck, -- Can make really cool setups with this
     diagnostics.cpplint, -- Google style guide
    --formatting.clang_format, -- Tool to format C/C++. Comes automatically with clangd from what I understand.
	},
   })
