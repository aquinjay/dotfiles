local M = {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },
    config = function()
      -- Lazily require the helper utilities from nvim-lspconfig so we can reuse
      -- the built-in project root detection helpers (e.g. `util.root_pattern`).
      local util = require "lspconfig.util"

      -- Advertise completion capabilities that match what nvim-cmp and other
      -- completion sources expect. Without snippet support Lua LSP completion
      -- results are noticeably degraded.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      -- Pull in optional user overrides for the lua-language-server (if the
      -- settings module exists). This keeps all user-tuned tweaks in one place
      -- while falling back to sane defaults when no overrides are provided.
      local settings = {}
      local ok, lua_settings = pcall(require, "user.plugins.lspsettings.lua_ls")
      if ok then
        settings = lua_settings
      end

      -- Compose the final lua-language-server configuration by combining our
      -- defaults with any user overrides gathered above. `vim.tbl_deep_extend`
      -- ensures nested tables (e.g. `settings` and `capabilities`) are merged
      -- correctly instead of being overwritten wholesale.
      local config = vim.tbl_deep_extend("force", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        -- Follow the same root directory detection logic used by lspconfig's
        -- built-in lua_ls module so that mason-installed servers Just Work.
        root_dir = function(fname)
          return util.root_pattern(
            ".luarc.json",
            ".luarc.jsonc",
            ".luacheckrc",
            ".stylua.toml",
            "stylua.toml",
            "selene.toml",
            "selene.yml",
            ".git"
          )(fname) or vim.fn.getcwd()
        end,
        single_file_support = true,
        capabilities = capabilities,
      }, settings)

      -- Register the configuration with the new `vim.lsp.config` API so the
      -- language server knows how to start when enabled.
      vim.lsp.config("lua_ls", config)

      -- Automatically enable lua_ls whenever a buffer with a matching filetype
      -- is opened. This mirrors the behaviour provided by lspconfig's plugin
      -- while keeping the configuration entirely within Neovim's core APIs.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = config.filetypes,
        callback = function()
          vim.lsp.enable("lua_ls")
        end,
      })
    end,
  },
}

return M
