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
--   • Neovim 0.11+ uses vim.lsp.config + vim.lsp.enable. This file centralizes that setup.
--   • nvim-lspconfig ships the base config for each server (cmd, filetypes,
--     root markers) in its lsp/<name>.lua files. We only layer our settings
--     on top, so root detection stays in the format Neovim expects.
--   • vim.lsp.enable() already starts servers by filetype; no autocmds needed.
--   • Other servers Mason installs (bashls, jsonls, basedpyright, ruff, ...)
--     are enabled by mason-lspconfig (see mason.lua).
--
-- Keys:
--   • <leader>lh → toggle inlay hints for the current buffer
--
-- Quick checks:
--   • :checkhealth vim.lsp (or :LspInfo) → “lua_ls” for Lua buffers
--   • :checkhealth vim.lsp → “vtsls” for TS/JS files, “vtsls” + “vue_ls” for .vue
--   • :lsp → interactively restart/stop clients (new in 0.12)
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
      ------------------------------------------------------------------------
      -- Capabilities (shared by every server via the "*" config)
      -- Why: nvim-cmp augments LSP completion behavior. Neovim's defaults
      --      already advertise snippet support, so no fallback is needed.
      ------------------------------------------------------------------------
      local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        vim.lsp.config("*", { capabilities = cmp_nvim_lsp.default_capabilities() })
      end

      ------------------------------------------------------------------------
      -- Inlay hints
      -- Why: useful but should only be turned on when the server supports them.
      --      LspAttach covers every server, including the ones Mason enables.
      ------------------------------------------------------------------------
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method("textDocument/inlayHint", ev.buf) then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
          end
        end,
      })

      vim.keymap.set("n", "<leader>lh", function()
        local filter = { bufnr = 0 }
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
      end, { desc = "Toggle inlay hints" })

      ------------------------------------------------------------------------
      -- LUA_LS
      -- Why: your config is Lua, so this keeps diagnostics/hover/completion
      --      accurate for Neovim APIs. Overrides live in lspsettings.lua_ls.
      ------------------------------------------------------------------------
      local ok_lua, lua_settings = pcall(require, "user.plugins.lspsettings.lua_ls")
      vim.lsp.config("lua_ls", vim.tbl_deep_extend("force", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            diagnostics = { globals = { "vim" } },
          },
        },
      }, ok_lua and lua_settings or {}))

      ------------------------------------------------------------------------
      -- VTSLS (TypeScript / JavaScript / TSX / Vue)
      -- Why: handles all TS/JS intelligence. vue_ls forwards TypeScript work in
      --      .vue files to vtsls (through @vue/typescript-plugin), so vtsls must
      --      attach to vue buffers too. filetypes/settings live in lspsettings.vtsls.
      ------------------------------------------------------------------------
      local ok_vts, vts = pcall(require, "user.plugins.lspsettings.vtsls")
      if ok_vts then
        vim.lsp.config("vtsls", { filetypes = vts.filetypes, settings = vts.settings })
      end

      ------------------------------------------------------------------------
      -- VUE_LS (Volar) — Vue 3 SFCs + template intelligence
      -- Why: this powers .vue templates, directives, and SFC-specific features.
      --      It delegates TS/JS to vtsls, which is why both run together.
      ------------------------------------------------------------------------
      local ok_volar, vol = pcall(require, "user.plugins.lspsettings.volar")
      vim.lsp.config("vue_ls", {
        settings = ok_volar and vol.settings or { vue = { format = { enable = true } } },
      })

      vim.lsp.enable { "lua_ls", "vtsls", "vue_ls" }
    end,
  },
}

return M
