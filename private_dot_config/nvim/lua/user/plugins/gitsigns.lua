-- lua/user/plugins/gitsigns.lua
-- Inline git hunk indicators, hunk navigation, preview, and hunk-level stage/reset.
-- Especially useful for reviewing and selectively accepting/reverting AI agent edits.

---@type LazyPluginSpec
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = function()
    local ok_icons, icons = pcall(require, "user.core.icons")
    local bar = (ok_icons and icons.ui and icons.ui.BoldLineLeft) or "▎"
    local del = (ok_icons and icons.ui and icons.ui.TriangleShortArrowRight) or ""

    return {
      signs = {
        add = { text = bar },
        change = { text = bar },
        delete = { text = del },
        topdelete = { text = del },
        changedelete = { text = bar },
        untracked = { text = "┆" },
      },
      signs_staged = {
        add = { text = bar },
        change = { text = bar },
        delete = { text = del },
        topdelete = { text = del },
        changedelete = { text = bar },
      },
      preview_config = {
        border = "rounded",
      },
      on_attach = function(bufnr)
        local gs = require "gitsigns"
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Hunk navigation (preserve default ]c / [c inside diff windows)
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            gs.nav_hunk "next"
          end
        end, "Next git hunk")

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            gs.nav_hunk "prev"
          end
        end, "Previous git hunk")

        -- Actions
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>gs", function()
          gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, "Stage selected hunk")
        map("v", "<leader>gr", function()
          gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, "Reset selected hunk")

        map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>gb", function()
          gs.blame_line { full = true }
        end, "Blame line")
        map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle inline git blame")
        map("n", "<leader>gD", gs.diffthis, "Diff current file")

        -- Hunk text object
        map({ "o", "x" }, "ih", gs.select_hunk, "Select git hunk")
      end,
    }
  end,
}
