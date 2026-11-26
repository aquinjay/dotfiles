-- lua/user/plugins/codecompanion.lua
-- Native in-buffer AI chat and actions powered by Antigravity (`agy acp`).
-- Uses Agent Client Protocol (ACP) over stdio so `agy` handles tools, context,
-- and permissions while prompts/responses live in a normal Neovim buffer.

---@type LazyPluginSpec
return {
  "olimorris/codecompanion.nvim",
  cmd = {
    "CodeCompanion",
    "CodeCompanionChat",
    "CodeCompanionActions",
    "CodeCompanionCmd",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    { "<leader>cc", "<cmd>CodeCompanionChat Toggle<CR>", mode = { "n", "v" }, desc = "CodeCompanion chat" },
    { "<leader>cA", "<cmd>CodeCompanionActions<CR>", mode = { "n", "v" }, desc = "CodeCompanion actions" },
    { "<leader>ci", "<cmd>CodeCompanion<CR>", mode = { "n", "v" }, desc = "CodeCompanion inline" },
    { "<leader>cx", "<cmd>CodeCompanionChat Add<CR>", mode = "v", desc = "Add selection to chat" },
  },
  opts = function()
    return {
      interactions = {
        chat = {
          adapter = "agy",
        },
        inline = {
          adapter = "agy",
        },
        cmd = {
          adapter = "agy",
        },
      },
      adapters = {
        acp = {
          agy = function()
            return require("codecompanion.adapters").extend("gemini_cli", {
              name = "agy",
              formatted_name = "Antigravity",
              commands = {
                default = { "agy", "acp" },
                yolo = { "agy", "acp", "--dangerously-skip-permissions" },
              },
            })
          end,
        },
      },
      display = {
        chat = {
          window = {
            layout = "vertical",
            width = 0.42,
            border = "rounded",
          },
        },
      },
    }
  end,
}
