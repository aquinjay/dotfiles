-- Illuminate highlights the other occurrences of the word under the cursor.
-- This spec keeps the plugin lazy-loaded and documents each tweak inline.
local M = {
  "RRethy/vim-illuminate",
  event = "VeryLazy",
}

function M.config()
  -- Pull the module once so we can reuse it for both configuration and keymaps.
  local illuminate = require("illuminate")

  illuminate.configure {
    -- Try LSP-powered references first, fall back to Treesitter, then plain text.
    providers = { "lsp", "treesitter", "regex" },

    -- A small delay keeps the highlights from flashing while you move quickly.
    delay = 150,

    -- Don’t light up prompt-style buffers or special-purpose plugin panels.
    filetypes_denylist = {
      "mason",
      "harpoon",
      "DressingInput",
      "NeogitCommitMessage",
      "qf",
      "dirvish",
      "oil",
      "minifiles",
      "fugitive",
      "alpha",
      "NvimTree",
      "lazy",
      "NeogitStatus",
      "Trouble",
      "netrw",
      "lir",
      "DiffviewFiles",
      "Outline",
      "Jaq",
      "spectre_panel",
      "toggleterm",
      "DressingSelect",
      "TelescopePrompt",
    },

    -- Skip the more expensive providers in very large files so navigation stays fast.
    large_file_cutoff = 2000,
    large_file_overrides = { providers = { "lsp" } },

    -- Require at least two matches before highlighting to avoid noise on keywords.
    min_count_to_highlight = 2,

    -- Keep the word under the cursor illuminated so the reference jumps are obvious.
    under_cursor = true,
  }

  -- Helper to register jump keymaps with consistent descriptions.
  local function map_reference(lhs, direction)
    local desc = direction == "next" and "Jump to next illuminated reference"
      or "Jump to previous illuminated reference"

    vim.keymap.set({ "n", "v", "o" }, lhs, function()
      if direction == "next" then
        illuminate.goto_next_reference(true)
      else
        illuminate.goto_prev_reference(true)
      end
    end, { desc = desc })
  end

  map_reference("]r", "next")
  map_reference("[r", "prev")
end

return M
