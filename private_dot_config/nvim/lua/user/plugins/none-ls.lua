--- @file none-ls.lua
--- @brief Configure the `nvimtools/none-ls.nvim` plugin to expose external
--- formatters and linters through Neovim's built-in LSP client.
local M = {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required runtime dependency for none-ls
  },
  event = { "BufReadPre", "BufNewFile" }, -- Lazily load when editing files
}

function M.config()
  ---@type table<string, any>
  local null_ls = require "null-ls"

  -- Extract helpers for readability and to avoid repeating `null_ls.builtins`
  local formatting = null_ls.builtins.formatting
  local diagnostics = null_ls.builtins.diagnostics
  local code_actions = null_ls.builtins.code_actions
  local utils = require "null-ls.utils"

  ---Create a convenience wrapper that keeps a source inactive when its backing
  ---executable is not available on the system. This prevents none-ls from
  ---spamming errors when a formatter/linter is missing.
  ---@param source null-ls.Source
  ---@param command string|nil
  local function with_executable(source, command)
    return source.with {
      condition = function()
        return utils.is_executable(command or source._opts.command)
      end,
    }
  end

  ---Restrict a source to projects that provide explicit configuration files.
  ---This keeps formatters like Stylua or Prettier from running on arbitrary
  ---projects that may not expect them.
  ---@param source null-ls.Source
  ---@param files string|string[]
  local function with_root_file(source, files)
    return source.with {
      condition = function()
        return utils.root_has_file(files)
      end,
    }
  end

  local sources = {
    -- Lua formatting only when a Stylua config is present
    with_root_file(formatting.stylua, { "stylua.toml", ".stylua.toml" }),

    -- JavaScript/TypeScript formatting using Prettierd when installed
    with_executable(formatting.prettierd, "prettierd"),

    -- Python formatters/linters (require the binaries in your PATH)
    with_executable(formatting.black.with { extra_args = { "--fast" } }, "black"),
    with_executable(formatting.isort, "isort"),
    with_executable(diagnostics.flake8, "flake8"),

    -- Shell integration
    with_executable(formatting.shfmt.with { extra_args = { "-i", "2", "-ci" } }, "shfmt"),
    with_executable(diagnostics.shellcheck, "shellcheck"),

    -- Git aware code actions (requires gitsigns dependency to be useful)
    code_actions.gitsigns,
  }

  local formatting_augroup = vim.api.nvim_create_augroup("NoneLsFormatting", { clear = true })

  null_ls.setup {
    debug = false, -- Enable for verbose logging if you need to troubleshoot
    sources = sources,
    on_attach = function(client, bufnr)
      -- Register a buffer-local format-on-save autocmd whenever the source
      -- advertises the formatting capability.
      if client.supports_method "textDocument/formatting" then
        vim.api.nvim_clear_autocmds { group = formatting_augroup, buffer = bufnr }
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = formatting_augroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format { bufnr = bufnr, async = false }
          end,
          desc = "Format with none-ls before saving the buffer",
        })
      end
    end,
  }
end

return M
