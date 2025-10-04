-- Reference settings: https://luals.github.io/wiki/settings/
-- This module returns the Lua LS configuration table consumed by the main LSP
-- setup.  Each section is annotated so it's obvious why a given option exists.
return {
  settings = {
    Lua = {
      format = {
        -- Formatting is delegated to another tool (stylua), so disable the LSP
        -- formatter to avoid conflicts.
        enable = false,
      },
      diagnostics = {
        -- `vim` is a global in Neovim configs and `spec` comes from busted
        -- tests/spec helpers.
        globals = { "vim", "spec" },
      },
      runtime = {
        -- Tell lua_ls it is running against LuaJIT and map `spec` to require so
        -- busted-style modules resolve correctly.
        version = "LuaJIT",
        special = {
          spec = "require",
        },
      },
      workspace = {
        -- Skip the third-party library prompt and add the Neovim runtime + user
        -- config directories so the language server can resolve imports.
        checkThirdParty = false,
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.stdpath "config" .. "/lua"] = true,
        },
      },
      hint = {
        -- Fine-grained inlay hint preferences.  These mirror what you would set
        -- via `:LspInlayHint` toggles but are persisted here.
        enable = true,
        arrayIndex = "Disable", -- "Enable" | "Auto" | "Disable"
        await = true,
        paramName = "Disable", -- "All" | "Literal" | "Disable"
        paramType = true,
        semicolon = "All", -- "All" | "SameLine" | "Disable"
        setType = false,
      },
      telemetry = {
        -- Opt out of telemetry when the server supports the flag.
        enable = false,
      },
    },
  },
}
