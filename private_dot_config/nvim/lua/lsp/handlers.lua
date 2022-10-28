local M = {} -- add to list M and will export at the end of the file so we can access all the non-local functions

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
	return
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)

M.setup = function()
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    -- disable virtual text
    virtual_text = false,
    -- show signs
    signs = {
      active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = { -- floating windows
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { -- shift k to hover over a word and see definition.
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

 -- See `:help vim.lsp.*` for documentation on any of the below functions
-- TODO: Need to be able to show which class a member belongs to.
local function lsp_keymaps(bufnr)
	local opts = { noremap = true, silent = true }
	local keymap = vim.api.nvim_buf_set_keymap
	keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts) --NOTE: Find where symbol is defined.
	keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts) --NOTE: Display information about symbol.
	keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- NOTE: Find where symbol is declared. Seems to not be supported so far.
	keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts) --NOTE: Find symbol of the same class across many files.
	keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", opts) --NOTE: Show diagnostics
	keymap(bufnr, "n", "gn", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>", opts) --NOTE: Show next diagnostic
	keymap(bufnr, "n", "gb", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<CR>", opts) --NOTE: Show previous diagnostic
	keymap(bufnr, "n", "<leader>lf", "<cmd>lua vim.lsp.buf.format()<cr>", opts) --NOTE: Format code.
	keymap(bufnr, "n", "<leader>lr", "<cmd>lua vim.lsp.buf.document_symbol()<cr>", opts) --NOTE: List all symbols
	--keymap(bufnr, "n", "<leader>li", "<cmd>LspInfo<cr>", opts)
	--keymap(bufnr, "n", "<leader>lI", "<cmd>LspInstallInfo<cr>", opts)
	keymap(bufnr, "n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts) 
	--keymap(bufnr, "n", "<leader>lj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", opts)
	--keymap(bufnr, "n", "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", opts)
	keymap(bufnr, "n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)-- NOTE: Rename all references to the symbol
	keymap(bufnr, "n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts) --WARN: Does not seem to work
	keymap(bufnr, "n", "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts) --NOTE: Show all diagnostics on a list.
end

M.on_attach = function(client, bufnr)
	if client.name == "denols" then
		client.server_capabilities.documentFormattingProvider = true
	end

	if client.name == "sumneko_lua" then
		client.server_capabilities.documentFormattingProvider = false
	end

	lsp_keymaps(bufnr)
	local status_ok, illuminate = pcall(require, "illuminate")
	if not status_ok then
		return
	end
	illuminate.on_attach(client)
end

return M


 -- add to list M and will export at the end of the file so we can access all the non-local functions

