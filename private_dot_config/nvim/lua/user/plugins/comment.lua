-- The base Comment.nvim specification.  This plugin provides motions for
-- toggling comments in normal/visual mode, so we load it eagerly instead of
-- waiting for a lazy trigger.
local M = {
  "numToStr/Comment.nvim",
  lazy = false,
  dependencies = {
    -- Context commentstring keeps the `commentstring` option in sync with the
    -- current Treesitter node (Lua, JSX, etc.) so comment delimiters are always
    -- correct.
    {
      "JoosepAlviste/nvim-ts-context-commentstring",
      event = "VeryLazy",
    },
  },
}

function M.config()
  -- Register the keymaps through which-key so the leader menu shows the
  -- comment action.  `<Plug>` mappings are used so Comment.nvim stays in
  -- control of the implementation details.
  local wk = require "which-key"
  wk.register {
    ["<leader>/"] = { "<Plug>(comment_toggle_linewise_current)", "Comment" },
  }

  wk.register {
    ["<leader>/"] = { "<Plug>(comment_toggle_linewise_visual)", "Comment", mode = "v" },
  }

  -- Comment.nvim handles integration with ts-context-commentstring itself, so
  -- we disable the built-in autocmd and wire the hook manually below.
  vim.g.skip_ts_context_commentstring_module = true
  ---@diagnostic disable: missing-fields
  require("ts_context_commentstring").setup {
    enable_autocmd = false,
  }

  -- Inject the pre-hook so Comment.nvim updates `commentstring` before any
  -- comment operation is executed.  This keeps JSX, Svelte, etc. working.
  require("Comment").setup {
    pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
  }
end

return M
