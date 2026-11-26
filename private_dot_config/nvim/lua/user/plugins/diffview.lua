-- lua/user/plugins/diffview.lua
-- Side-by-side multi-file git diff and file history review.

---@type LazyPluginSpec
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diff view (repo)" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File git history" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Repo git history" },
    { "<leader>gx", "<cmd>DiffviewClose<CR>", desc = "Close diff view" },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = {
        layout = "diff2_horizontal",
      },
      merge_tool = {
        layout = "diff3_mixed",
      },
    },
  },
}
