-- Core purpose: shared config for the vtsls server.
-- - filetypes: which buffers should attach to vtsls (includes vue so vue_ls can find TS)
-- - settings: inlay hints + completion preferences for TS/JS
local M = {}

M.filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue" }

M.settings = {
  typescript = {
    preferences = {
      includeCompletionsWithSnippetText = true,
      includeCompletionsWithClassMemberSnippets = true,
    },
    inlayHints = {
      enumMemberValues = { enabled = true },
      functionLikeReturnTypes = { enabled = true },
      parameterNames = { enabled = "literals" },
      parameterTypes = { enabled = true },
      propertyDeclarationTypes = { enabled = true },
      variableTypes = { enabled = false },
    },
  },
  javascript = {
    inlayHints = {
      parameterNames = { enabled = "literals" },
      parameterTypes = { enabled = true },
    },
  },
}

return M
