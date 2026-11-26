-- lua/user/plugins/treesitter_textobjects.lua
-- Syntax-aware text objects (af/if, ac/ic, aa/ia) and function/class jumps
-- using nvim-treesitter-textobjects (main branch for Neovim 0.12).

---@type LazyPluginSpec
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    { "nvim-treesitter/nvim-treesitter", branch = "main" },
  },
  config = function()
    require("nvim-treesitter-textobjects").setup {
      select = {
        lookahead = true,
        selection_modes = {
          ["@parameter.outer"] = "v",
          ["@function.outer"] = "V",
          ["@class.outer"] = "V",
        },
        include_surrounding_whitespace = false,
      },
      move = {
        set_jumps = true,
      },
    }

    local select = require "nvim-treesitter-textobjects.select"
    local move = require "nvim-treesitter-textobjects.move"

    -- Text objects (visual + operator-pending)
    local select_maps = {
      { "af", "@function.outer", "Outer function" },
      { "if", "@function.inner", "Inner function" },
      { "ac", "@class.outer", "Outer class / struct" },
      { "ic", "@class.inner", "Inner class / struct" },
      { "aa", "@parameter.outer", "Outer parameter / argument" },
      { "ia", "@parameter.inner", "Inner parameter / argument" },
    }
    for _, m in ipairs(select_maps) do
      vim.keymap.set({ "x", "o" }, m[1], function()
        select.select_textobject(m[2], "textobjects")
      end, { desc = m[3] })
    end

    -- Function & class movement
    local move_maps = {
      { "]m", "goto_next_start", "@function.outer", "Next function start" },
      { "[m", "goto_previous_start", "@function.outer", "Previous function start" },
      { "]M", "goto_next_end", "@function.outer", "Next function end" },
      { "[M", "goto_previous_end", "@function.outer", "Previous function end" },
      { "]]", "goto_next_start", "@class.outer", "Next class start" },
      { "[[", "goto_previous_start", "@class.outer", "Previous class start" },
    }
    for _, m in ipairs(move_maps) do
      vim.keymap.set({ "n", "x", "o" }, m[1], function()
        move[m[2]](m[3], "textobjects")
      end, { desc = m[4] })
    end
  end,
}
