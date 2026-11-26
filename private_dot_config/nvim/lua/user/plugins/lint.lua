-- lua/user/plugins/lint.lua
-- Async linting via nvim-lint for tools without a dedicated linter LSP.
-- (Bash shellcheck is handled by bashls; Python by ruff; C++ by clangd --clang-tidy.)

---@type LazyPluginSpec
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require "lint"

    lint.linters_by_ft = {
      fish = { "fish" },
    }

    local group = vim.api.nvim_create_augroup("user_nvim_lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = group,
      callback = function()
        if vim.bo.modifiable and vim.bo.buftype == "" then
          lint.try_lint()
        end
      end,
    })

    vim.keymap.set("n", "<leader>lL", function()
      lint.try_lint()
    end, { desc = "Run linter" })
  end,
}
