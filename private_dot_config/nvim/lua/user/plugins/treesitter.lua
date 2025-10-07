-- lua/user/plugins/treesitter.lua
-- ============================================================================
-- 🧭 QUICK REFERENCE — Treesitter
--
-- What this file does
--   • Installs & configures parsers for fast, accurate syntax highlighting.
--   • Enables incremental selection (expand/shrink selection by syntax node).
--   • Enables indent powered by trees (where parsers support it).
--   • Auto-installs missing parsers on demand.
--   • Skips Treesitter on very large files to avoid lag.
--
-- How to use
--   • Selection: <CR> to expand, <BS> to shrink (in visual/select mode).
--     (Change keys below if you prefer.)
--   • Run :TSUpdate occasionally to keep parsers fresh (also done on build).
--
-- Extend later (easy bolt-ons)
--   • Textobjects: add "nvim-treesitter/nvim-treesitter-textobjects".
--   • Context commentstring: add "JoosepAlviste/nvim-ts-context-commentstring".
--   • Autotag for HTML/TSX: add "windwp/nvim-ts-autotag".
-- ============================================================================

---@type LazyPluginSpec
local M = {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
}

function M.config()
  -- Heuristic: disable Treesitter on very large files to keep things snappy.
  local function too_large(lang, buf)
    local max_filesize = 200 * 1024 -- 200 KB
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
    if ok and stats and stats.size > max_filesize then
      vim.schedule(function()
        vim.notify(("Treesitter disabled for large %s file (> %d KB)"):format(lang, max_filesize / 1024),
          vim.log.levels.INFO)
      end)
      return true
    end
    return false
  end

  require("nvim-treesitter.configs").setup {
    -- Install just what you use; add more as needed.
    ensure_installed = {
      "lua",
      "markdown",
      "markdown_inline",
      "bash",
      "python",
      "json",
      "yaml",
      "toml",
      "regex",
      "vim",
      "vimdoc",
      -- add: "typescript","tsx","html","css","go","rust","cpp" ...
    },

    -- Parser management
    sync_install = false,     -- async installs are fine
    auto_install = true,      -- install missing parsers when entering buffer
    ignore_install = {},

    -- Highlighting
    highlight = {
      enable = true,
      disable = function(lang, buf) return too_large(lang, buf) end,
      additional_vim_regex_highlighting = false, -- avoid double-highlighting
    },

    -- Indentation (parser-specific; falls back gracefully where unsupported)
    indent = {
      enable = true,
      disable = function(lang, buf) return too_large(lang, buf) end,
    },

    -- Incremental selection (super handy for refactors)
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>",       -- start selection at cursor
        node_incremental = "<CR>",     -- grow to next node
        scope_incremental = "<S-CR>",  -- grow to scope
        node_decremental = "<BS>",     -- shrink
      },
    },

    -- If you use "andymass/vim-matchup", Treesitter can improve it:
    matchup = { enable = true },

    -- If you add autotag plugin later:
    -- autotag = { enable = true },
    --
    -- If you add context-commentstring plugin later (pairs nicely with Comment.nvim):
    -- context_commentstring = { enable = true, enable_autocmd = false },
  }
end

return M
