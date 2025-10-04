--NOTE: mason.nvim is a Neovim plugin that allows you to easily manage external editor tooling such as LSP servers, DAP servers, linters, and formatters through a single interface.
-- Mason is basically the menu you see when a plugin gets installed now.

--NOTE:mason-lspconfig.nvim closes some gaps that exist between mason.nvim and lspconfig. Its main responsibilities are to:
--register a setup hook with lspconfig that ensures servers installed with mason.nvim are set up with the necessary configuration
--provide extra convenience APIs such as the :LspInstall command
--allow you to (i) automatically install, and (ii) automatically set up a predefined list of servers
--translate between lspconfig server names and mason.nvim package names (e.g. lua_ls <-> lua-language-server)
local M = {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
  },
}

---Merge two lists into a unique array while filtering out empty values.
---This lets us keep a sensible default LSP set while still allowing overrides
---from user configuration without installing duplicates.
---@param defaults string[]
---@param overrides string[]|string|nil
---@return string[]
local function merge_unique(defaults, overrides)
  local merged = {}
  local seen = {}
  local trim = (vim and vim.trim)
    or function(value)
      return (value:gsub("^%s*(.-)%s*$", "%1"))
    end

  local function add(value)
    if type(value) ~= "string" then
      return
    end

    local trimmed = trim(value)
    if trimmed ~= "" and not seen[trimmed] then
      table.insert(merged, trimmed)
      seen[trimmed] = true
    end
  end

  for _, value in ipairs(defaults) do
    add(value)
  end

  if type(overrides) == "string" then
    overrides = { overrides }
  end

  if type(overrides) == "table" then
    for _, value in ipairs(overrides) do
      add(value)
    end
  end

  return merged
end


function M.config()
  -- Default language servers that should always be installed.
  local default_servers = {
    "lua_ls",   -- Lua language server for Neovim development.
    "pyright",  -- Type checker and language server for Python.
    "bashls",   -- Bash language server for shell scripting.
    "jsonls",   -- JSON language server with schema support.
  }

  -- Allow the list to be extended or trimmed via a global.
  -- Example: vim.g.mason_lsp_servers = { "tsserver", "gopls" }
  local user_servers = rawget(vim.g, "mason_lsp_servers")
  local servers = merge_unique(default_servers, user_servers)

  -- Mason core setup -------------------------------------------------------
  local mason_ok, mason = pcall(require, "mason")
  if not mason_ok then
    vim.notify("mason.nvim is not available", vim.log.levels.ERROR)
    return
  end

  mason.setup {
    ui = {
      border = "rounded", -- Consistent floating window borders.
      check_outdated_packages_on_open = true, -- Surface outdated tools early.
      icons = {
        package_installed = "",
        package_pending = "",
        package_uninstalled = "",
      },
    },
    max_concurrent_installers = 4, -- Keep installer throughput high but safe.
  }

  -- Mason-LSPconfig bridge -------------------------------------------------
  local mason_lsp_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
  if not mason_lsp_ok then
    vim.notify("mason-lspconfig.nvim is not available", vim.log.levels.ERROR)
    return
  end

  mason_lspconfig.setup {
    ensure_installed = servers, -- Auto-install both defaults and user additions.
    automatic_installation = true, -- Ensure new servers are fetched on demand.
  }

  -- Optional handler auto-setup --------------------------------------------
  -- If nvim-lspconfig is available we register a generic handler so any
  -- server installed through Mason is automatically initialised. Users can
  -- override individual server settings by creating
  -- `user/lsp/settings/<server>.lua` modules that return option tables.
  local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
  if not lspconfig_ok then
    return -- Nothing more to do if the LSP client isn't present.
  end

  mason_lspconfig.setup_handlers {
    function(server_name)
      local opts = {}

      local has_custom_opts, custom_opts = pcall(require, "user.lsp.settings." .. server_name)
      if has_custom_opts then
        if type(custom_opts) == "function" then
          custom_opts = custom_opts()
        end

        if type(custom_opts) == "table" then
          opts = vim.tbl_deep_extend("force", opts, custom_opts)
        else
          vim.notify(
            string.format(
              "mason-lspconfig: expected table from user.lsp.settings.%s, got %s",
              server_name,
              type(custom_opts)
            ),
            vim.log.levels.WARN
          )
        end
      end

      local server = lspconfig[server_name]
      if not server then
        vim.notify(
          string.format("mason-lspconfig: no lspconfig entry for %s", server_name),
          vim.log.levels.WARN
        )
        return
      end

      server.setup(opts)
    end,
  }
end

return M
