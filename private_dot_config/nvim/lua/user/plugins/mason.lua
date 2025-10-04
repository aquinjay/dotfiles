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

---Utility trim helper that falls back when `vim.trim` is unavailable.
---@param value string
---@return string
local function trim(value)
  if vim and vim.trim then
    return vim.trim(value)
  end

  return (value:gsub("^%s*(.-)%s*$", "%1"))
end

---Small helper to safely emit notifications even when `vim.notify`
---is overridden or unavailable (e.g. during headless validation).
---@param message string
---@param level integer
local function notify(message, level)
  if vim and vim.notify then
    vim.notify(message, level)
    return
  end

  local label = tostring(level)
  if vim and vim.log and vim.log.levels then
    for name, value in pairs(vim.log.levels) do
      if value == level then
        label = name
        break
      end
    end
  end

  print(string.format("[mason-lspconfig][%s] %s", label, message))
end

---Normalise mixed input (string, table, or nil) into a list of strings.
---@param value string|string[]|nil
---@return string[]
local function normalize_list(value)
  if type(value) == "string" then
    return { trim(value) }
  end

  if type(value) ~= "table" then
    return {}
  end

  local result = {}
  for _, entry in ipairs(value) do
    if type(entry) == "string" then
      local trimmed = trim(entry)
      if trimmed ~= "" then
        table.insert(result, trimmed)
      end
    end
  end

  return result
end

---Compose the effective ensure_installed list.
---Supports default values, user additions, and opt-out lists to keep
---local customisations out of version-controlled defaults.
---@param defaults string[]
---@param additions string[]
---@param removals string[]
---@return string[]
local function build_server_list(defaults, additions, removals)
  local remove_lookup = {}

  for _, name in ipairs(removals) do
    if type(name) == "string" then
      remove_lookup[trim(name)] = true
    end
  end

  local result = {}
  local seen = {}

  local function add(value)
    if type(value) ~= "string" then
      return
    end

    local trimmed = trim(value)
    if trimmed == "" or remove_lookup[trimmed] or seen[trimmed] then
      return
    end

    table.insert(result, trimmed)
    seen[trimmed] = true
  end

  for _, value in ipairs(defaults) do
    add(value)
  end

  for _, value in ipairs(additions) do
    add(value)
  end

  return result
end

---Merge a user override table into default options.
---@param base table
---@param override table
---@return table
local function deep_merge(base, override)
  if type(override) ~= "table" or next(override) == nil then
    return base
  end

  if vim and vim.tbl_deep_extend then
    local ok, merged = pcall(vim.tbl_deep_extend, "force", base, override)
    if ok then
      return merged
    end
  end

  for key, value in pairs(override) do
    if type(value) == "table" and type(base[key]) == "table" then
      base[key] = deep_merge(base[key], value)
    else
      base[key] = value
    end
  end

  return base
end


function M.config()
  -- Default language servers that should always be installed.
  local default_servers = {
    "lua_ls",   -- Lua language server for Neovim development.
    "pyright",  -- Type checker and language server for Python.
    "bashls",   -- Bash language server for shell scripting.
    "jsonls",   -- JSON language server with schema support.
  }

  -- Allow the list to be extended or trimmed via globals.
  -- Examples:
  --   vim.g.mason_lsp_servers = { "tsserver", "gopls" }
  --   vim.g.mason_lsp_servers_remove = { "jsonls" }
  local additions = normalize_list(rawget(vim.g, "mason_lsp_servers"))
  local removals = normalize_list(
    rawget(vim.g, "mason_lsp_servers_remove")
      or rawget(vim.g, "mason_lsp_servers_exclude")
  )
  local servers = build_server_list(default_servers, additions, removals)

  -- Mason core setup -------------------------------------------------------
  local mason_ok, mason = pcall(require, "mason")
  if not mason_ok then
    notify("mason.nvim is not available", vim.log.levels.ERROR)
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
    notify("mason-lspconfig.nvim is not available", vim.log.levels.ERROR)
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
          opts = deep_merge(opts, custom_opts)
        else
          notify(
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
        notify(
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
