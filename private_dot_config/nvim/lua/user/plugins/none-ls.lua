--NOTE: Neovim doesn't provide a way for non-LSP sources to hook into its LSP client. null-ls is an attempt to bridge that gap and simplify the process of creating, sharing, and setting up LSP sources using pure Lua.
local M = {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim"
  }
}

function M.config()
  local null_ls = require "null-ls"

  local formatting = null_ls.builtins.formatting
  local diagnostics =  null_ls.builtins.diagnostics
  local actions = null_ls.builtins.code_actions

  null_ls.setup {
    debug = false,
    sources = {
      -- Lua
      formatting.stylua, -- Add formatters and linters
      --formatting.prettier,
      -- formatting.prettier.with {
      --   extra_filetypes = { "toml" },
      --   -- extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
      -- },
      -- formatting.eslint,
      -- null_ls.builtins.diagnostics.flake8,
      -- Python 
      formatting.black.with({extra_args = {"--fast"}, filetypes = {"python"}}),
      -- diagnostics.flake8, -- python linter
      -- null_ls.builtins.completion.spell,

      -- Shell 
      --actions.shellcheck, -- Linter aka check for errors/warnings 
      --diagnostics.shellcheck,
      --formatting.shfmt, -- shell formatter, parser, and interpreter

      ---- C++
      --diagnostics.cppcheck, -- Can make really cool setups with this
      --diagnostics.cpplint, -- Google style guide

      ----formatting.clang_format, -- Tool to format C/C++. Comes automatically with clangd from what I understand.
      ---- CMake 
      --diagnostics.cmake_lint,
      --formatting.cmake_format,
    },
  }
end

return M
