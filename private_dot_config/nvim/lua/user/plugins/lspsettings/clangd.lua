-- lua/user/plugins/lspsettings/clangd.lua
-- C/C++ language server using the system /usr/bin/clangd so compiler and
-- standard library headers match the host toolchain.

return {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
}
