
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
    enable_if_exec(d.ruff, "ruff"),
    enable_if_exec(f.ruff, "ruff"),
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
