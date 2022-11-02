-- Again, LSP enables the editor and the lsp to have a common language to communicate in. One language to rule them all. Still need to install formatting, linting etc.
local servers = {
	"sumneko_lua",
	"cssls",
	"html",
	--"tsserver",  --NOTE: replaced by denols
	"pyright",
	"bashls",
	"jsonls",
	"yamlls",
  "clangd",
  "cmake",
  "denols",
  --"r_language_server",
  "volar", -- Better than vuels
  --"vuels",
  "dockerls",
}

local settings = {
	ui = {
		border = "none",
		icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
		},
	},
	log_level = vim.log.levels.INFO,
	max_concurrent_installers = 4,
}

require("mason").setup(settings)
require("mason-lspconfig").setup({
	ensure_installed = servers,
	automatic_installation = true,
})

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
	return
end

local opts = {}

for _, server in pairs(servers) do
	opts = {
		on_attach = require("lsp.handlers").on_attach,
		capabilities = require("lsp.handlers").capabilities,
	}

	server = vim.split(server, "@")[1]

	local require_ok, conf_opts = pcall(require, "lsp.settings." .. server)
	if require_ok then
		opts = vim.tbl_deep_extend("force", conf_opts, opts)
	end

	lspconfig[server].setup(opts)
end
