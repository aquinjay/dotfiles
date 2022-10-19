-----------------------------------------------------------
-- Autocomplete configuration file
-----------------------------------------------------------

-- Plugin: nvim-cmp
-- url: https://github.com/hrsh7th/nvim-cmp


local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

require("luasnip/loaders/from_vscode").lazy_load() -- enable lazy loading for vscode related snippets

-- Makes super-tabbing more intuitive. So clicking tab will take you into next piece of snippet while navigating snippet. Does more than that but enables powerful intuitive features.
local check_backspace = function()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

-- Nerd Font symbols
--   פּ ﯟ   some other good icons
local kind_icons = {
  Text = "",
  Method = "m",
  Function = "",
  Constructor = "",
  Field = "",
  Variable = "",
  Class = "",
  Interface = "",
  Module = "",
  Property = "",
  Unit = "",
  Value = "",
  Enum = "",
  Keyword = "",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "",
  Event = "",
  Operator = "",
  TypeParameter = "",
}
-- find more here: https://www.nerdfonts.com/cheat-sheet

-- Below comes from nvim-cmp configuration recomendation
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ["<C-k>"] = cmp.mapping.select_prev_item(), -- vim like navigation through supertab.
		["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }), -- can scroll through big menu
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }), -- can scroll through big menu
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }), -- can see all completions without typing
    ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ["<C-e>"] = cmp.mapping { -- exit completion
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ["<CR>"] = cmp.mapping.confirm { select = true }, -- confirm our selection and make window disapear
    ["<Tab>"] = cmp.mapping(function(fallback) -- super tab power
      if cmp.visible() then
        cmp.select_next_item()-- if menu is visable select next item
      elseif luasnip.expandable() then -- if you can expand a luan snippet do that
        luasnip.expand()
      elseif luasnip.expand_or_jumpable() then -- if expandable and jumpable then jump
        luasnip.expand_or_jump()
      elseif check_backspace() then -- make backspace like a tab if you can go back
        fallback()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
    ["<S-Tab>"] = cmp.mapping(function(fallback) -- same as above but for shift-tab
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
  },
  formatting = { --How should the completion menu be formatted. kind symbol, abbreviation, then menu. kind is just an arbitrary name we are giving it.
    fields = { "kind", "abbr", "menu" },
    format = function(entry, vim_item)
      -- Kind icons
      vim_item.kind = string.format("%s", kind_icons[vim_item.kind]) -- one of two mutually exclusive kind
      -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
      vim_item.menu = ({ 
        nvim_lsp = "[LSP]",
        nvim_lua = "[LUA]",
        luasnip = "[Luasnip]",
        buffer = "[File]",
        path = "[Path]",
      })[entry.source.name]
      return vim_item
    end,
  },
  sources = { -- order of suggestions. Above those is the lsp completion stuff that will be in next video. Delete this comment later.
    { name = "nvim_lsp" }, -- fed from cmp-nvim-lsp package.
    { name = "nvim_lua" }, -- fed from cmp-nvim-lua package.
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  },
  confirm_opts = {
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  },
  window = { -- shows documentation. Set = false if you want gone.
    documentation = {
      border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    },
  },
  experimental = {
    ghost_text = true, -- can start to see ghost of completion. virtual text,
    native_menu = false, -- Not sure what this does here.
  },
}
