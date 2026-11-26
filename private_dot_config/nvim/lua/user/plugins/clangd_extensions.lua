-- lua/user/plugins/clangd_extensions.lua
-- Extra C/C++ commands for clangd (AST, type hierarchy, memory usage, symbol info)
-- and score-based completion sorting for nvim-cmp.

---@type LazyPluginSpec
return {
  "p00f/clangd_extensions.nvim",
  ft = { "c", "cpp", "objc", "objcpp", "cuda" },
  opts = {
    inlay_hints = {
      inline = false, -- Neovim 0.12 native inlay hints are already enabled in lspconfig.lua
    },
    ast = {
      role_icons = {
        type = "",
        declaration = "",
        expression = "",
        specifier = "",
        statement = "",
        ["template argument"] = "",
      },
      kind_icons = {
        Compound = "",
        Recovery = "",
        TranslationUnit = "",
        PackExpansion = "",
        TemplateTypeParm = "",
        TemplateTemplateParm = "",
        TemplateParamObject = "",
      },
    },
  },
}
