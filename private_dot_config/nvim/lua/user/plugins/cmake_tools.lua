-- lua/user/plugins/cmake_tools.lua
-- CMake configure/build/run/debug workflow + automatic compile_commands.json
-- symlink so clangd resolves project headers and clang-tidy checks automatically.

---@type LazyPluginSpec
return {
  "Civitasv/cmake-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = {
    "CMakeGenerate",
    "CMakeBuild",
    "CMakeRun",
    "CMakeDebug",
    "CMakeSelectBuildTarget",
    "CMakeSelectLaunchTarget",
    "CMakeSelectBuildType",
    "CMakeSelectKit",
    "CMakeClean",
    "CMakeOpenExecutor",
    "CMakeOpenRunner",
  },
  keys = {
    { "<leader>mg", "<cmd>CMakeGenerate<CR>", desc = "CMake generate" },
    { "<leader>mb", "<cmd>CMakeBuild<CR>", desc = "CMake build" },
    { "<leader>mr", "<cmd>CMakeRun<CR>", desc = "CMake run" },
    { "<leader>md", "<cmd>CMakeDebug<CR>", desc = "CMake debug (DAP)" },
    { "<leader>mt", "<cmd>CMakeSelectBuildTarget<CR>", desc = "Select build target" },
    { "<leader>ml", "<cmd>CMakeSelectLaunchTarget<CR>", desc = "Select launch target" },
    { "<leader>mT", "<cmd>CMakeSelectBuildType<CR>", desc = "Select build type" },
    { "<leader>mc", "<cmd>CMakeClean<CR>", desc = "CMake clean" },
  },
  init = function()
    local loaded = false
    local function maybe_load()
      if loaded then
        return
      end
      local cwd = vim.uv.cwd()
      if cwd and vim.fn.filereadable(vim.fs.joinpath(cwd, "CMakeLists.txt")) == 1 then
        loaded = true
        require("lazy").load { plugins = { "cmake-tools.nvim" } }
      end
    end
    maybe_load()
    vim.api.nvim_create_autocmd("DirChanged", {
      group = vim.api.nvim_create_augroup("user_cmake_autoload", { clear = true }),
      callback = maybe_load,
    })
  end,
  opts = {
    cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
    cmake_compile_commands_options = {
      action = "soft_link",
    },
    cmake_dap_configuration = {
      name = "CMake GDB Debug",
      type = "gdb",
      request = "launch",
      stopAtBeginningOfMainSubprogram = false,
    },
  },
}
