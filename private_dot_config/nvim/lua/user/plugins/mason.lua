-- mason.nvim manages external tooling (LSP servers, linters, formatters, etc.)
-- mason-lspconfig bridges mason and Neovim's LSP client configuration.
local M = {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
  },
}

local function to_list(value)
  if type(value) == "string" then
    return { value }
  end

  if type(value) == "table" then
    return value
  end

  return {}
end

local function collect_servers(defaults)
  local wanted = {}
  local seen = {}

  for _, name in ipairs(defaults) do
    if type(name) == "string" and name ~= "" and not seen[name] then
      table.insert(wanted, name)
      seen[name] = true
    end
  end

  for _, name in ipairs(to_list(vim.g.mason_lsp_servers)) do
    if type(name) == "string" then
      name = vim.trim(name)
      if name ~= "" and not seen[name] then
        table.insert(wanted, name)
        seen[name] = true
      end
    end
  end

  local removals = {}
  for _, name in ipairs(
    to_list(vim.g.mason_lsp_servers_remove or vim.g.mason_lsp_servers_exclude)
  ) do
    if type(name) == "string" then
      removals[vim.trim(name)] = true
    end
  end

  if next(removals) == nil then
    return wanted
  end

  local filtered = {}
  for _, name in ipairs(wanted) do
    if not removals[name] then
      table.insert(filtered, name)
    end
  end

  return filtered
end

function M.config()
  local mason = require "mason"
  mason.setup {
    ui = {
      border = "rounded",
    },
  }

  local mason_lspconfig = require "mason-lspconfig"
  mason_lspconfig.setup {
    ensure_installed = collect_servers {
      "lua_ls",
      "pyright",
      "bashls",
      "jsonls",
    },
    automatic_installation = true,
    handlers = {
      function(server_name)
        local config = vim.deepcopy(vim.lsp.config(server_name) or {})

        local ok, overrides = pcall(require, "user.lsp.settings." .. server_name)
        if ok then
          if type(overrides) == "function" then
            overrides = overrides()
          end

          if type(overrides) == "table" then
            config = vim.tbl_deep_extend("force", config, overrides)
          end
        end

        vim.lsp.config(server_name, config)

        local filetypes = config.filetypes
        if type(filetypes) == "string" then
          filetypes = { filetypes }
        end

        if type(filetypes) == "table" and #filetypes > 0 then
          vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("UserMasonLsp", { clear = false }),
            pattern = filetypes,
            callback = function()
              vim.lsp.enable(server_name)
            end,
          })
        end
      end,
    },
  }
end

return M
