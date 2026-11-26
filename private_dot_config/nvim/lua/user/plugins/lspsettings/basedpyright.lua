-- lua/user/plugins/lspsettings/basedpyright.lua
-- Python type checking and intelligence via basedpyright.
-- Import sorting and linting/formatting are delegated to ruff.

return {
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      analysis = {
        typeCheckingMode = "standard",
        autoImportCompletions = true,
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        inlayHints = {
          variableTypes = true,
          callArgumentNames = true,
          functionReturnTypes = true,
          genericTypes = false,
        },
      },
    },
  },
}
