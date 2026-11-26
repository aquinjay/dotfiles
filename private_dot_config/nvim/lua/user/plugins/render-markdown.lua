-- lua/user/plugins/render-markdown.lua
-- ============================================================================
-- 🧭 QUICK REFERENCE — render-markdown.nvim
--
-- What this does
--   • Draws markdown in the buffer: styled headings, real table borders,
--     Obsidian callouts, checkboxes, code blocks, ==highlights==, wikilink icons.
--   • The "obsidian" preset renders in every mode (like Obsidian Live Preview);
--     only the line under the cursor goes back to raw markdown so you can edit.
--   • Completes callout types (> [!...) and checkbox states via in-process LSP.
--
-- Keys
--   • <leader>nm → toggle rendered / raw markdown (all markdown buffers)
--
-- Notes
--   • LaTeX ($$ blocks) renders as unicode when `latex2text` is installed
--     (pacman: python-pylatexenc) and the `latex` treesitter parser is present.
--   • Images, Datacore, Excalidraw and mermaid only render in the Obsidian app:
--     <leader>no opens the current note there (it live-reloads on every save).
--
-- Quick checks
--   • :checkhealth render-markdown
-- ============================================================================

---@type LazyPluginSpec
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "codecompanion" },
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },

  keys = {
    { "<leader>nm", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle rendered markdown" },
  },

  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    file_types = { "markdown", "codecompanion" },
    preset = "obsidian",
    completions = { lsp = { enabled = true } },
    code = {
      -- Size code blocks to their content instead of the full window width.
      width = "block",
      right_pad = 1,
    },
  },
}
