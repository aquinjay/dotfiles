-- lua/user/plugins/neotest.lua
-- Inline test runner for Python (pytest) and C++ (GoogleTest).

---@type LazyPluginSpec
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-python",
    "alfaix/neotest-gtest",
  },
  keys = {
    { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
    { "<leader>tf", function() require("neotest").run.run(vim.fn.expand "%") end, desc = "Run test file" },
    { "<leader>ta", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run all tests" },
    { "<leader>td", function() require("neotest").run.run { strategy = "dap" } end, desc = "Debug nearest test" },
    { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
    {
      "<leader>to",
      function()
        require("neotest").output.open { enter = true, auto_close = true }
      end,
      desc = "Show test output",
    },
    { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle test output panel" },
    { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop test run" },
    { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand "%") end, desc = "Toggle test watch" },
    { "]t", function() require("neotest").jump.next { status = "failed" } end, desc = "Next failed test" },
    { "[t", function() require("neotest").jump.prev { status = "failed" } end, desc = "Previous failed test" },
  },
  config = function()
    local adapters = {
      require "neotest-python" {
        dap = { justMyCode = false },
        runner = "pytest",
      },
      require("neotest-gtest").setup {},
    }

    require("neotest").setup {
      adapters = adapters,
      floating = {
        border = "rounded",
      },
      output = {
        open_on_run = false,
      },
      quickfix = {
        open = false,
      },
    }
  end,
}
