-- Core purpose: shared config for the vtsls server.
-- - filetypes: which buffers should attach to vtsls (includes vue so vue_ls can find TS)
-- - settings: inlay hints + completion preferences for TS/JS, and the
--   @vue/typescript-plugin that vue_ls (v3+) relies on for <script> blocks
local M = {}

M.filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "vue" }

-- Mason's vue-language-server package bundles the TypeScript plugin.
local vue_plugin_path = vim.fn.stdpath "data" .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

M.settings = {
  vtsls = {
    tsserver = {
      globalPlugins = {
        {
          name = "@vue/typescript-plugin",
          location = vue_plugin_path,
          languages = { "vue" },
          configNamespace = "typescript",
          enableForWorkspaceTypeScriptVersions = true,
        },
      },
    },
  },
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
