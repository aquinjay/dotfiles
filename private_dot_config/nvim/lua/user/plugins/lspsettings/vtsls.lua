-- Vue/TS stack: vtsls handles TS/JS(/TSX). Volar will handle .vue
local M = {}

M.filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }

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

