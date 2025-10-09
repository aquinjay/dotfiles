-- lua/user/plugins/none-ls.lua
-- ============================================================================
-- 🧭 QUICK REFERENCE — "none-ls" (formerly null-ls)
--
-- ▸ What this does
--   Bridges external formatters and linters into Neovim’s LSP system so they
--   act like normal language servers (same diagnostics, same format-on-save).
--
-- ▸ Active tools
--   • stylua → formats Lua (only if stylua.toml exists)
--   • biome  → formats JS/TS/JSON/CSS/GraphQL (only if biome.json/jsonc exists)
--
-- ▸ Where they come from
--   Mason can install them (`:Mason` → stylua / biome)  
--   or install manually:
--     - stylua: cargo install stylua
--     - biome:  npm i -g @biomejs/biome
--
-- ▸ Quick checks
--     :echo executable("stylua")
--     :echo executable("biome")
--   → should print `1`; `0` means Neovim can’t find it on $PATH.
--
-- ▸ How formatting runs
--   If an attached client supports `textDocument/formatting`, none-ls hooks
--   `BufWritePre` and runs the formatter just before write.
--
-- ▸ Where configs live
--   • stylua → stylua.toml or .stylua.toml  
--   • biome  → biome.json or biome.jsonc
--
-- ▸ Adding more tools later
--   1. Install the CLI tool (e.g., shfmt, black, prettier).  
--   2. Copy one of the helper patterns in “wanted” below.  
--   3. Save → reload → done.
--
-- ▸ Debugging
--   • :NoneLsInfo    → shows active sources per buffer
--   • :checkhealth   → checks executables on PATH
--
-- Typical flow:
--   open → none-ls attaches → save → formatter runs → done.
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
    enable_if_root_file(f.biome,{ "biome.json", "biome.jsonc" })
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
