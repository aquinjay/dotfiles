-- nvim-cmp is the main completion engine that powers insert- and command-line
-- completion. The plugin spec eagerly lists every source we reference in the
-- setup block so lazy.nvim can resolve them automatically.
local M = {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-emoji",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lua",
    {
      "L3MON4D3/LuaSnip",
      build = (function()
        -- Some LuaSnip features depend on jsregexp. Only try to compile it when the
        -- toolchain is available so we do not break install on minimal systems.
        if vim.fn.executable "make" == 1 then
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
  local cmp = require "cmp"
  local luasnip = require "luasnip"

  -- Enable snippet history so jumping backwards restores previous selections,
  -- and refresh snippets as you type. This mirrors upstream recommendations.
  luasnip.config.setup {
    history = true,
    updateevents = "TextChanged,TextChangedI",
  }
  -- Load VS Code style snippets on demand. This keeps startup light while still
  -- offering the large community snippet set when completion first runs.
  require("luasnip.loaders.from_vscode").lazy_load()

  -- Give emoji completion items their own highlight so they stand out.
  vim.api.nvim_set_hl(0, "CmpItemKindEmoji", { fg = "#FDE030" })

  -- Helper that checks whether there are non-whitespace characters before the
  -- cursor. We use it to decide if <Tab> should trigger completion.
  local function has_words_before()
    local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
    if col == 0 then
      return false
    end

    local current_line = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1] or ""
    local previous_char = current_line:sub(col, col)
    return previous_char:match "%s" == nil
  end

  local icons = require "user.core.icons"

  cmp.setup {
    snippet = {
      -- Tell nvim-cmp how to expand LuaSnip snippets.
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    -- Map commonly used keys to familiar completion behaviours.
    mapping = cmp.mapping.preset.insert {
      ["<C-k>"] = cmp.mapping.select_prev_item(),
      ["<C-j>"] = cmp.mapping.select_next_item(),
      ["<Down>"] = cmp.mapping.select_next_item(),
      ["<Up>"] = cmp.mapping.select_prev_item(),
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      -- Accept the currently selected item, defaulting to the first suggestion.
      ["<CR>"] = cmp.mapping.confirm { select = true },
      -- Use <Tab> and <S-Tab> to navigate suggestions, expand snippets, or
      -- fall back to their native behaviour when completion is not relevant.
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
    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        -- Swap cmp's generic kind icons for the ones defined in user.core.icons.
        vim_item.kind = icons.kind[vim_item.kind] or vim_item.kind
        -- Annotate each source so you know where a suggestion originates.
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          nvim_lua = "[Lua]",
          luasnip = "[Snippet]",
          buffer = "[Buffer]",
          path = "[Path]",
          emoji = "[Emoji]",
        })[entry.source.name]

        if entry.source.name == "emoji" then
          vim_item.kind = icons.misc.Smiley
          vim_item.kind_hl_group = "CmpItemKindEmoji"
        end

        return vim_item
      end,
    },
    -- Pull completion items from LSP, snippets, the current buffer, file paths,
    -- the Neovim Lua runtime, and emoji.
    sources = cmp.config.sources {
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "nvim_lua" },
      { name = "buffer" },
      { name = "path" },
      { name = "emoji" },
    },
    confirm_opts = {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
    window = {
      -- Use borders for completion and documentation windows. Disabling the
      -- completion scrollbar keeps the layout clean on narrow terminals.
      completion = cmp.config.window.bordered {
        scrollbar = false,
      },
      documentation = cmp.config.window.bordered(),
    },
    experimental = {
      ghost_text = false,
    },
  }

  -- Enable buffer-scoped completion when searching with / or ?. This mirrors
  -- the default Neovim behaviour while still offering cmp's UI.
  cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
    },
  })

  -- For : commands we mix file path suggestions with Neovim's command line
  -- completion. cmp.config.sources handles prioritisation automatically.
  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      { name = "cmdline" },
    }),
  })

  -- Seamlessly insert matching pairs ("(", "[", etc.) after confirming
  -- completion items when nvim-autopairs is available.
  local autopairs_loaded, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
  if autopairs_loaded then
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end
end

return M
