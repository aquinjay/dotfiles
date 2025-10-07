-- lua/user/plugins/lspconfig.lua
-- ============================================================================
-- 🧭 QUICK REFERENCE — LSP (lua_ls focused)
--
-- What this file does
--   • Configures the Lua language server using Neovim’s core API
--     (vim.lsp.config / vim.lsp.enable), not lspconfig’s sugar.
--   • Injects nvim-cmp completion capabilities so snippet/doc features show up.
--   • Enables inlay hints automatically when the server supports them.
--   • Allows optional user overrides in `user.plugins.lspsettings.lua_ls`.
--
-- Typical check:
--   • :LspInfo → “lua_ls” attached when editing Lua.
--   • Hover/definitions work; completion menu is driven by nvim-cmp.
-- ============================================================================

local M = {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
      -- NOTE: cmp-nvim-lsp is declared in your cmp spec; we *optionally* require it below.
      -- "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Reuse lspconfig's root helpers
      local util = require "lspconfig.util"

      ------------------------------------------------------------------------
      -- Capabilities — prefer cmp’s defaults; fall back to snippetSupport only
      ------------------------------------------------------------------------
      local capabilities
      local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = cmp_nvim_lsp.default_capabilities()
      else
        capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true
      end

      ------------------------------------------------------------------------
      -- Minimal on_attach: enable inlay hints if available
      ------------------------------------------------------------------------
      local function on_attach(client, bufnr)
        if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          pcall(vim.lsp.inlay_hint, bufnr, true)
        end
      end

      ------------------------------------------------------------------------
      -- Optional user overrides (your existing pattern)
      ------------------------------------------------------------------------
      local settings = {}
      local ok, lua_settings = pcall(require, "user.plugins.lspsettings.lua_ls")
      if ok then settings = lua_settings end

      -- Compose final config (keep your structure intact)
      local config = vim.tbl_deep_extend("force", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_dir = function(fname)
          return util.root_pattern(
            ".luarc.json",
            ".luarc.jsonc",
            ".luacheckrc",
            ".stylua.toml",
            "stylua.toml",
            "selene.toml",
            "selene.yml",
            ".git"
          )(fname) or vim.fn.getcwd()
        end,
        single_file_support = true,
        capabilities = capabilities,  -- ✅ cmp capabilities
        on_attach = on_attach,        -- ✅ inlay hints hook
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            diagnostics = { globals = { "vim" } },
          },
        },
      }, settings)

      -- Register + enable via the core API (your original approach)
      vim.lsp.config("lua_ls", config)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = config.filetypes,
        callback = function() vim.lsp.enable("lua_ls") end,
      })
    end,
  },
}

return M
