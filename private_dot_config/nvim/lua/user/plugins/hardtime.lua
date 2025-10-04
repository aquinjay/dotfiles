local M = {
  "m4xshen/hardtime.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  event = "VeryLazy",
  -- Encourage practicing efficient navigation while avoiding disruption in special buffers.
  opts = {
    disable_mouse = false,
    disabled_filetypes = {
      "neo-tree",
      "lazy",
      "mason",
      "help",
      "qf",
      "TelescopePrompt",
    },
    restriction_mode = "hint",
    restricted_keys = {
      ["h"] = { "n", "x" },
      ["j"] = { "n", "x" },
      ["k"] = { "n", "x" },
      ["l"] = { "n", "x" },
      ["-"] = { "n", "x" },
      ["+"] = { "n", "x" },
      ["gj"] = { "n", "x" },
      ["gk"] = { "n", "x" },
    },
  },
}

return M
