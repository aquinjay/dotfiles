-- lua/user/plugins/treesitter.lua
-- ============================================================================
-- 🧭 QUICK REFERENCE — Treesitter
--
-- What this file does
--   • Installs parsers + queries via nvim-treesitter (main branch).
--   • Starts Neovim's built-in treesitter highlighting per buffer.
--   • Enables indent powered by trees (where parsers support it).
--   • Auto-installs missing parsers on demand.
--   • Skips Treesitter on very large files to avoid lag.
--   • Maps incremental selection onto Neovim 0.12's built-in node selection.
--
-- Why it looks like this (Neovim 0.12)
--   • nvim-treesitter's old `master` branch is frozen and breaks on 0.12
--     (its query directives crash markdown injections). The `main` branch is a
--     rewrite: it only installs parsers/queries. Highlighting, folds, and
--     selection are now core Neovim features we switch on ourselves.
--   • Requires `tree-sitter-cli` (pacman: tree-sitter-cli) + a C compiler.
--
-- How to use
--   • Selection: <CR> to start/expand, <BS> to shrink (visual mode).
--     Built-in equivalents also work: `an` (outwards), `in` (inwards),
--     `]n`/`[n` (next/prev node). See :h treesitter-incremental-selection
--   • Run :TSUpdate occasionally to keep parsers fresh (also done on build).
--   • :checkhealth nvim-treesitter → parser/tooling status.
--
-- Extend later (easy bolt-ons)
--   • Textobjects: add "nvim-treesitter/nvim-treesitter-textobjects" (main branch).
--   • Autotag for HTML/TSX: add "windwp/nvim-ts-autotag".
-- ============================================================================

---@type LazyPluginSpec
local M = {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- the main branch does not support lazy-loading
  build = ":TSUpdate",
}

function M.config()
  local ts = require "nvim-treesitter"

  -- Install just what you use; add more as needed. No-op if already installed.
  ts.install {
    "lua",
    "markdown",
    "markdown_inline",
    "bash",
    "python",
    "vue",
    "typescript",
    "tsx",
    "javascript",
    "html",
    "css",
    "scss",
    "json",
    "yaml",
    "toml",
    "regex",
    "vim",
    "vimdoc",
    -- add: "go","rust","cpp" ...
  }

  -- Heuristic: disable Treesitter on very large files to keep things snappy.
  local function too_large(lang, buf)
    local max_filesize = 200 * 1024 -- 200 KB
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
    if ok and stats and stats.size > max_filesize then
      vim.schedule(function()
        vim.notify(("Treesitter disabled for large %s file (> %d KB)"):format(lang, max_filesize / 1024),
          vim.log.levels.INFO)
      end)
      return true
    end
    return false
  end

  -- Languages nvim-treesitter knows how to install (built once, on first use).
  local available
  local function is_available(lang)
    if not available then
      available = {}
      for _, l in ipairs(ts.get_available()) do
        available[l] = true
      end
    end
    return available[lang]
  end

  local function attach(buf, lang)
    if not vim.api.nvim_buf_is_valid(buf) then return end

    -- Highlighting (regex syntax stays off to avoid double-highlighting)
    if not pcall(vim.treesitter.start, buf, lang) then return end

    -- Indentation (experimental in nvim-treesitter). Vue stays off because its
    -- mixed-language indent queries misbehave while editing .vue files.
    if lang ~= "vue" then
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end

    -- Incremental selection: keep the old keys, backed by 0.12's built-in
    -- `an`/`in` visual mappings (which fall back to LSP selectionRange).
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, remap = true, silent = true, desc = desc })
    end
    map("n", "<CR>", "van", "Start syntax selection")
    map("x", "<CR>", "an", "Expand syntax selection")
    map("x", "<BS>", "in", "Shrink syntax selection")
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
    callback = function(ev)
      local lang = vim.treesitter.language.get_lang(ev.match)
      if not lang then return end

      if too_large(lang, ev.buf) then
        -- Some filetypes (e.g. markdown) start treesitter from their ftplugin,
        -- which runs after this autocmd, so stop it once that has happened.
        vim.schedule(function() pcall(vim.treesitter.stop, ev.buf) end)
        return
      end

      if vim.treesitter.language.add(lang) then
        attach(ev.buf, lang)
      elseif is_available(lang) then
        -- auto_install: fetch the missing parser, then attach.
        ts.install(lang):await(function(err)
          if not err then
            vim.schedule(function() attach(ev.buf, lang) end)
          end
        end)
      end
    end,
  })
end

return M
