-- lua/user/plugins/conform.lua
-- Manual formatting across Python, Bash/Fish, C/C++, Lua, and JS/TS via conform.nvim.
-- Format-on-save is intentionally disabled; trigger manually with <leader>lf.

---@type LazyPluginSpec
return {
  "stevearc/conform.nvim",
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>lf",
      function()
        require("conform").format { async = true, lsp_format = "fallback" }
      end,
      mode = { "n", "v" },
      desc = "Format buffer / selection",
    },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
  opts = {
    -- Format-on-save intentionally off.
    format_on_save = false,
    default_format_opts = {
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      python = { "ruff_organize_imports", "ruff_format" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      fish = { "fish_indent" },
      c = { "clang-format" },
      cpp = { "clang-format" },
      lua = { "stylua" },
      javascript = { "biome" },
      javascriptreact = { "biome" },
      typescript = { "biome" },
      typescriptreact = { "biome" },
      vue = { "biome" },
      json = { "biome" },
      jsonc = { "biome" },
      css = { "biome" },
    },
    formatters = {
      stylua = {
        condition = function(_, ctx)
          return vim.fs.find({ "stylua.toml", ".stylua.toml" }, { path = ctx.filename, upward = true })[1] ~= nil
        end,
      },
      biome = {
        condition = function(_, ctx)
          return vim.fs.find({ "biome.json", "biome.jsonc" }, { path = ctx.filename, upward = true })[1] ~= nil
        end,
      },
    },
  },
}
