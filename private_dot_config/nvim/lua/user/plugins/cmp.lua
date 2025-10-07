-- lua/user/plugins/cmp.lua
-- ============================================================================
-- 🧭 QUICK REFERENCE — nvim-cmp (completion engine)
--
-- What this does
--   • Routes multiple completion sources (LSP, snippets, buffer, paths) into one menu.
--   • Handles UI, keymaps, and how items are confirmed/expanded.
--
-- How LSP fits in
--   • LSP is *a source* (via cmp-nvim-lsp). Servers provide items; cmp shows them.
--   • We pass cmp "capabilities" to LSP (see lspconfig file) so servers enable
--     richer completion (snippets, etc.).
--
-- Sources enabled
--   • LSP, LuaSnip, buffer, path, Neovim Lua API, emoji (remove if you don’t want it).
--
-- Keys / usage
--   • <C-j>/<C-k> or <Tab>/<S-Tab> to navigate, <CR> to confirm.
--   • Snippets expand & jump with <Tab>.
--   • :CmpToggle → globally pause/resume completion (handy when writing prose).
--
-- Tuning noise
--   • Buffer source uses `keyword_length = 3` by default; raise to 4–5 if spammy.
-- ============================================================================
---@type LazyPluginSpec
local M = {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    -- SOURCES
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-emoji",
    -- SNIPPETS
    {
      "L3MON4D3/LuaSnip",
      build = (function()
        if vim.fn.executable("make") == 1 then
          return "make install_jsregexp"
        end
      end)(),
      dependencies = {
        "rafamadriz/friendly-snippets",
      },
    },
  },
}

function M.config()
  vim.opt.completeopt = { "menu", "menuone", "noselect" }

  local cmp = require "cmp"
  local luasnip = require "luasnip"

  -- Snippets ------------------------------------------------------------------
  luasnip.config.setup {
    history = true,
    updateevents = "TextChanged,TextChangedI",
  }
  require("luasnip.loaders.from_vscode").lazy_load()

  -- Optional: make emoji kind stand out
  pcall(vim.api.nvim_set_hl, 0, "CmpItemKindEmoji", { fg = "#FDE030" })

  local function has_words_before()
    local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
    if col == 0 then return false end
    local current = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1] or ""
    return current:sub(col, col):match("%s") == nil
  end

  local ok_icons, icons = pcall(require, "user.core.icons")
  local kind_icons = ok_icons and icons.kind or {}
  local misc_icons = ok_icons and icons.misc or {}

  -- A tiny on/off switch you can toggle with :CmpToggle -----------------------
  local cmp_enabled = true
  vim.api.nvim_create_user_command("CmpToggle", function()
    cmp_enabled = not cmp_enabled
    vim.notify(("nvim-cmp: %s"):format(cmp_enabled and "enabled" or "disabled"))
  end, { desc = "Toggle nvim-cmp completion" })

  -- Core setup ----------------------------------------------------------------
  cmp.setup {
    enabled = function() return cmp_enabled end,

    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },

    mapping = cmp.mapping.preset.insert {
      ["<C-k>"] = cmp.mapping.select_prev_item(),
      ["<C-j>"] = cmp.mapping.select_next_item(),
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm { select = true },
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    },

    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "nvim_lua" },
    }, {
      { name = "buffer", keyword_length = 3 },
      { name = "path" },
      { name = "emoji" },
    }),

    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        vim_item.kind = kind_icons[vim_item.kind] or vim_item.kind
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          nvim_lua = "[Lua]",
          luasnip  = "[Snip]",
          buffer   = "[Buf]",
          path     = "[Path]",
          emoji    = "[Emoji]",
        })[entry.source.name]

        if entry.source.name == "emoji" then
          vim_item.kind = misc_icons.Smiley or "🙂"
          vim_item.kind_hl_group = "CmpItemKindEmoji"
        end

        local max = 50
        if #vim_item.abbr > max then
          vim_item.abbr = vim_item.abbr:sub(1, max - 1) .. "…"
        end
        return vim_item
      end,
    },

    window = {
      completion = cmp.config.window.bordered { scrollbar = false },
      documentation = cmp.config.window.bordered(),
    },

    experimental = { ghost_text = false },

    performance = {
      debounce = 20,
      throttle = 30,
      fetching_timeout = 200,
    },
  }

  -- Commandline completion ----------------------------------------------------
  cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = "buffer" } },
  })

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
  })

  -- Autopairs integration (safe if plugin missing) ---------------------------
  local ok_pairs, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
  if ok_pairs then
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end
end

return M
