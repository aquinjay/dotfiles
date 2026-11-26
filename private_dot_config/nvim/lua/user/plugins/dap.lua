-- lua/user/plugins/dap.lua
-- Debugging via nvim-dap + nvim-dap-view:
--   • Python: debugpy (installed via Mason) + nvim-dap-python
--   • C / C++: native GDB 14+ DAP (`gdb --interpreter=dap`)

---@type LazyPluginSpec
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "igorlfs/nvim-dap-view",
      version = "1.*",
      opts = {
        winbar = {
          sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
          default_section = "scopes",
        },
        windows = {
          size = 0.30,
          position = "below",
        },
      },
    },
    {
      "mfussenegger/nvim-dap-python",
      ft = "python",
    },
  },
  keys = {
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "Conditional breakpoint",
    },
    { "<leader>dc", function() require("dap").continue() end, desc = "Debug: start / continue" },
    { "<F5>", function() require("dap").continue() end, desc = "Debug: start / continue" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
    { "<F11>", function() require("dap").step_into() end, desc = "Step into" },
    { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
    { "<F10>", function() require("dap").step_over() end, desc = "Step over" },
    { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
    { "<F12>", function() require("dap").step_out() end, desc = "Step out" },
    { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to cursor" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate debug session" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "Run last debug config" },
    { "<leader>du", "<cmd>DapViewToggle<CR>", desc = "Toggle DAP view" },
    { "<leader>dw", "<cmd>DapViewWatch<CR>", mode = { "n", "v" }, desc = "Add expression to watches" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle DAP REPL" },
  },
  config = function()
    local dap = require "dap"
    local dap_view = require "dap-view"

    -- Auto-open / close dap-view with debug sessions
    dap.listeners.before.attach.dapview_config = function()
      dap_view.open()
    end
    dap.listeners.before.launch.dapview_config = function()
      dap_view.open()
    end
    dap.listeners.before.event_terminated.dapview_config = function()
      dap_view.close()
    end
    dap.listeners.before.event_exited.dapview_config = function()
      dap_view.close()
    end

    -- Breakpoint / execution signs
    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
    vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint" })
    vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DiagnosticInfo" })
    vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual" })

    -- Python (debugpy installed via Mason)
    local ok_py, dap_python = pcall(require, "dap-python")
    if ok_py then
      local mason_py = vim.fs.joinpath(vim.fn.stdpath "data", "mason", "packages", "debugpy", "venv", "bin", "python")
      local py_bin = vim.uv.fs_stat(mason_py) and mason_py or "python3"
      dap_python.setup(py_bin)
      dap_python.test_runner = "pytest"
    end

    -- C / C++ via native GDB 14+ DAP support
    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
    }

    local cpp_configs = {
      {
        name = "Launch executable (GDB)",
        type = "gdb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.uv.cwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
      },
      {
        name = "Launch executable with args (GDB)",
        type = "gdb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.uv.cwd() .. "/", "file")
        end,
        args = function()
          local input = vim.fn.input("Arguments: ")
          return vim.split(input, " ", { trimempty = true })
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
      },
      {
        name = "Attach to process (GDB)",
        type = "gdb",
        request = "attach",
        pid = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
      },
    }

    dap.configurations.cpp = cpp_configs
    dap.configurations.c = cpp_configs
  end,
}
