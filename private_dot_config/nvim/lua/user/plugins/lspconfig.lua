-- lua/user/plugins/lspconfig.lua
-- Core purpose: register LSP server configs and enable them by filetype.
-- ============================================================================
-- 🧭 QUICK REFERENCE — LSP (Lua, TypeScript, Vue)
--
-- What this file does
--   • Configures multiple language servers (Lua, TS/JS, Vue) via Neovim’s core API.
--   • Keeps Lua, vue_ls (Vue), and VTSLS (TS/JS) separate—no conflicts.
--   • Injects nvim-cmp completion capabilities + inlay hints.
--   • Optional per-server overrides live in user.plugins.lspsettings/*.lua
--
-- Why this exists (in plain terms):
--   • Neovim 0.11 uses vim.lsp.config + vim.lsp.enable. This file centralizes that setup.
--   • It makes LSP startup explicit and filetype-driven, so you always know what runs where.
--   • It avoids the "magic" of per-server setup scattered across plugins.
--
-- Quick checks:
--   • :LspInfo → “lua_ls” for Lua buffers
--   • :LspInfo → “vtsls” for TS/JS files
--   • :LspInfo → “vue_ls” for .vue files
-- ============================================================================

local M = {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },

    config = function()
      local util = require "lspconfig.util"

      ------------------------------------------------------------------------
      -- Capabilities
      -- Why: nvim-cmp augments LSP completion behavior. If cmp isn't available,
      --      we still enable snippet support so servers can return rich items.
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
      -- Minimal on_attach
      -- Why: inlay hints are useful but should only be turned on when supported
      --      by the server and the Neovim API.
      ------------------------------------------------------------------------
      local function on_attach(client, bufnr)
        if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          pcall(vim.lsp.inlay_hint, bufnr, true)
        end
      end

      ------------------------------------------------------------------------
      -- LUA_LS
      -- Why: your config is Lua, so this keeps diagnostics/hover/completion
      --      accurate for Neovim APIs. Overrides live in lspsettings.lua_ls.
      ------------------------------------------------------------------------
      local settings = {}
      local ok, lua_settings = pcall(require, "user.plugins.lspsettings.lua_ls")
      if ok then settings = lua_settings end

      local lua_cfg = vim.tbl_deep_extend("force", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_dir = util.root_pattern(
          ".luarc.json",
          ".luarc.jsonc",
          ".luacheckrc",
          ".stylua.toml",
          "stylua.toml",
          "selene.toml",
          "selene.yml",
          ".git"
        ),
        single_file_support = true,
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            diagnostics = { globals = { "vim" } },
          },
        },
      }, settings)

      vim.lsp.config("lua_ls", lua_cfg)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = lua_cfg.filetypes,
        callback = function() vim.lsp.enable("lua_ls") end,
      })

      ------------------------------------------------------------------------
      -- VTSLS (TypeScript / JavaScript / TSX / Vue)
      -- Why: handles all TS/JS intelligence. vue_ls expects a TS client to be
      --      active for script blocks inside .vue files, so vtsls must attach
      --      to vue buffers too. filetypes live in lspsettings.vtsls.
      ------------------------------------------------------------------------
      local ok_vts, vts = pcall(require, "user.plugins.lspsettings.vtsls")
      local vts_cfg = {
        cmd = { "vtsls" },
        filetypes = ok_vts and vts.filetypes
          or { "typescript", "typescriptreact", "javascript", "javascriptreact" },
        root_dir = util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git"),
        single_file_support = true,
        capabilities = capabilities,
        on_attach = on_attach,
        settings = ok_vts and vts.settings or {},
      }
      vim.lsp.config("vtsls", vts_cfg)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = vts_cfg.filetypes,
        callback = function() vim.lsp.enable("vtsls") end,
      })

      ------------------------------------------------------------------------
      -- VUE_LS (Volar) — Vue 3 SFCs + template intelligence
      -- Why: this powers .vue templates, directives, and SFC-specific features.
      --      It delegates TS/JS to vtsls, which is why both run together.
      --      It prefers workspace TypeScript so versions match your project.
      ------------------------------------------------------------------------
      local ok_volar, vol = pcall(require, "user.plugins.lspsettings.volar")
      local tsdk = ""
      do
        local ts_path = util.path.join(vim.loop.cwd() or "", "node_modules", "typescript", "lib")
        if vim.loop.fs_stat(ts_path) then tsdk = ts_path end
      end

      local vue_cfg = {
        cmd = { "vue-language-server", "--stdio" },
        filetypes = { "vue" },
        root_dir = util.root_pattern(
          "pnpm-workspace.yaml",
          "yarn.lock",
          "package-lock.json",
          "package.json",
          ".git"
        ),
        single_file_support = true,
        capabilities = capabilities,
        on_attach = on_attach,
        settings = ok_volar and vol.settings or {
          vue = { format = { enable = true } },
          typescript = { tsdk = tsdk },
        },
      }
      vim.lsp.config("vue_ls", vue_cfg)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = vue_cfg.filetypes,
        callback = function() vim.lsp.enable("vue_ls") end,
      })
    end,
  },
}

return M
