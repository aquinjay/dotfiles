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
-- Keys (set on LspAttach unless noted):
--   • gd / gD / gI → definition / declaration / implementation
--   • gl           → line diagnostic float
--   • <leader>la   → code action (n/v)
--   • <leader>lr   → rename symbol
--   • <leader>lf   → format buffer
--   • <leader>lh   → toggle inlay hints (global)
--   • <leader>ld   → toggle inline diagnostic virtual text (global)
--   • <leader>lj/k → next / prev diagnostic (or built-in ]d / [d)
--   • <leader>ls/S → document / workspace symbols (Telescope)
--   • <leader>li   → :checkhealth vim.lsp
--   • Built-ins    → K (hover), grn, gra, grr, gri, grt, grx, gO, [d/]d
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
      -- Diagnostics UI (Neovim 0.12 native API)
      ------------------------------------------------------------------------
      local ok_icons, icons = pcall(require, "user.core.icons")
      local diag_icons = (ok_icons and icons.diagnostics) or {
        Error = "",
        Warning = "",
        Hint = "󰌶",
        Information = "",
      }

      vim.diagnostic.config {
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = diag_icons.Error,
            [vim.diagnostic.severity.WARN] = diag_icons.Warning,
            [vim.diagnostic.severity.HINT] = diag_icons.Hint,
            [vim.diagnostic.severity.INFO] = diag_icons.Information,
          },
        },
        virtual_text = false,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        jump = {
          on_jump = function(diagnostic, bufnr)
            if diagnostic then
              vim.diagnostic.open_float { bufnr = bufnr, scope = "cursor", focus = false }
            end
          end,
        },
        float = {
          focusable = true,
          style = "minimal",
          border = "rounded",
          source = "if_many",
          header = "",
          prefix = "",
        },
      }

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
      -- LspAttach: inlay hints + buffer-local LSP keymaps
      -- Covers every server, including servers enabled by mason-lspconfig.
      ------------------------------------------------------------------------
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client then
            if client:supports_method("textDocument/inlayHint", ev.buf) then
              vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
            end
            -- Let basedpyright own hover docs in Python buffers.
            if client.name == "ruff" then
              client.server_capabilities.hoverProvider = false
            end
          end

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
          end

          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gI", vim.lsp.buf.implementation, "Go to implementation")
          map("n", "gl", vim.diagnostic.open_float, "Line diagnostics")

          map({ "n", "x" }, "<leader>la", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>lr", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<leader>ll", vim.lsp.codelens.run, "Run CodeLens")
          map("n", "<leader>li", "<cmd>checkhealth vim.lsp<CR>", "LSP info")
          map("n", "<leader>lq", vim.diagnostic.setloclist, "Diagnostics to loclist")
          map("n", "<leader>lj", function()
            vim.diagnostic.jump { count = 1 }
          end, "Next diagnostic")
          map("n", "<leader>lk", function()
            vim.diagnostic.jump { count = -1 }
          end, "Previous diagnostic")
          map("n", "<leader>ls", function()
            require("telescope.builtin").lsp_document_symbols()
          end, "Document symbols")
          map("n", "<leader>lS", function()
            require("telescope.builtin").lsp_dynamic_workspace_symbols()
          end, "Workspace symbols")

          if client and client.name == "clangd" then
            map("n", "<leader>lc", "<cmd>LspClangdSwitchSourceHeader<CR>", "Switch C/C++ source/header")
          end
        end,
      })

      vim.keymap.set("n", "<leader>lh", function()
        local filter = { bufnr = 0 }
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
      end, { desc = "Toggle inlay hints" })

      vim.keymap.set("n", "<leader>ld", function()
        local current = vim.diagnostic.config().virtual_text
        vim.diagnostic.config { virtual_text = not current }
        vim.notify(("Diagnostic virtual text: %s"):format(current and "off" or "on"))
      end, { desc = "Toggle diagnostic virtual text" })

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

      ------------------------------------------------------------------------
      -- PYTHON: basedpyright + ruff (enabled by mason-lspconfig)
      ------------------------------------------------------------------------
      local ok_bp, bp = pcall(require, "user.plugins.lspsettings.basedpyright")
      if ok_bp then
        vim.lsp.config("basedpyright", bp)
      end

      local ok_ruff, ruff = pcall(require, "user.plugins.lspsettings.ruff")
      if ok_ruff then
        vim.lsp.config("ruff", ruff)
      end

      ------------------------------------------------------------------------
      -- C / C++: system clangd
      ------------------------------------------------------------------------
      local ok_clangd, clangd = pcall(require, "user.plugins.lspsettings.clangd")
      if ok_clangd then
        vim.lsp.config("clangd", clangd)
      end

      vim.lsp.enable { "lua_ls", "vtsls", "vue_ls", "clangd" }
    end,
  },
}

return M
