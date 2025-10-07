-- lua/user/plugins/none-ls.lua
-- ============================================================================
-- 🧭 QUICK REFERENCE — "none-ls" (formerly null-ls)
--
-- Q: What is this file?
-- A: It wires external formatters & linters into Neovim’s LSP system so they
--    behave like language servers (same diagnostics, same format-on-save).
--
-- Q: What tools does it run?
-- A: Right now only two:
--      • stylua → formats Lua (only if stylua.toml exists)
--      • ruff   → lints + formats Python (only if ruff binary is found)
--
-- Q: Where do these tools come from?
-- A: Mason can install them (`:Mason` → select “stylua” / “ruff”), or you can
--    install manually via pipx / cargo / system package manager.
--
-- Q: How do I check if they’re visible to Neovim?
-- A: Inside Neovim:
--        :echo executable("ruff")
--        :echo executable("stylua")
--    Each should print `1`.  If `0`, Neovim can’t find it on $PATH.
--
-- Q: What happens when I save a file?
-- A: If the attached LSP client supports formatting, none-ls runs its formatter
--    right before write (`BufWritePre`).  Lua files use stylua; Python uses ruff.
--
-- Q: Where are the rules / settings?
-- A: Each tool reads its own config:
--        • stylua → stylua.toml or .stylua.toml
--        • ruff   → pyproject.toml under [tool.ruff] / [tool.ruff.format]
--
-- Q: How do I add another language later?
-- A: 1. Install the CLI tool (e.g., shfmt, eslint_d, black, etc.).
--    2. In “wanted” below, copy one of the helper lines:
--         enable_if_exec(null_ls.builtins.formatting.shfmt, "shfmt")
--    3. Save → reload → done.
--
-- Q: How do I debug when nothing runs?
-- A: `:NoneLsInfo` shows active sources per buffer.
--    `:checkhealth` verifies the executables.
--
-- Typical workflow:
--   1. Open a file.
--   2. None-ls attaches (you’ll see it in :LspInfo).
--   3. On save → formatter runs.
--   4. Ruff/stylua warnings show inline like normal diagnostics.
--
-- ============================================================================
---@type LazyPluginSpec
local M = {
  "nvimtools/none-ls.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = { "BufReadPre", "BufNewFile" },
}

function M.config()
  local null_ls = require "null-ls"
  local f = null_ls.builtins.formatting
  local d = null_ls.builtins.diagnostics

  -- Helper: only enable if tool exists
  local function enable_if_exec(source, cmd)
    if not source then return nil end
    return source.with {
      condition = function() return vim.fn.executable(cmd) == 1 end,
    }
  end

  -- Helper: only enable if project declares config file
  local function enable_if_root_file(source, files)
    if not source then return nil end
    return source.with {
      condition = function(utils) return utils.root_has_file(files) end,
    }
  end

  -- Current minimal setup
  local wanted = {
    enable_if_root_file(f.stylua, { "stylua.toml", ".stylua.toml" }),
  }

  local sources = {}
  for _, s in ipairs(wanted) do
    if s then table.insert(sources, s) end
  end

  local aug = vim.api.nvim_create_augroup("NoneLsFormat", { clear = true })

  null_ls.setup {
    debug = false,
    sources = sources,
    on_attach = function(client, bufnr)
      if client.supports_method "textDocument/formatting" then
        vim.api.nvim_clear_autocmds { group = aug, buffer = bufnr }
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = aug,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format { bufnr = bufnr, async = false }
          end,
          desc = "Format via none-ls on save",
        })
      end
    end,
  }
end

return M
