local M = {
  "hrsh7th/nvim-cmp", -- Core completion engine for Neovim, provides autocomplete functionality.

  -- Triggers the plugin's loading when entering insert mode.
  event = "InsertEnter",

  -- List of plugins that nvim-cmp depends on for providing various completions.
  dependencies = {
    {
      "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp, provides LSP-based completions.
      event = "InsertEnter", 
    },
    {
      "hrsh7th/cmp-emoji", -- Emoji completion source for nvim-cmp.
      event = "InsertEnter",  
    },
    {
      "hrsh7th/cmp-buffer", -- Provides completion items from the current buffer.
      event = "InsertEnter", 
    },
    {
      "hrsh7th/cmp-path", -- Path completion source, offers filesystem path completions.
      event = "InsertEnter",  
    },
    {
      "hrsh7th/cmp-cmdline", -- Provides command line completion in Neovim's command mode.
      event = "InsertEnter",  
    },
    {
      "saadparwaiz1/cmp_luasnip", -- Integrates LuaSnip snippets into nvim-cmp completions.
      event = "InsertEnter",  
    },
    {
      "L3MON4D3/LuaSnip", -- Snippet engine, allows inserting predefined code blocks.
      event = "InsertEnter",  
      dependencies = {"rafamadriz/friendly-snippets"}, -- Collection of snippets for various programming languages.
    },
    {
      "hrsh7th/cmp-nvim-lua", -- Provides Neovim Lua API completions.
      -- This plugin is always loaded, no specific event required.
    },
  },
}

-- Configuration function for nvim-cmp
function M.config()
  local cmp = require "cmp" --modules stored in variables so I can use their functionality within the configuration file
  local luasnip = require "luasnip"
  require("luasnip/loaders/from_vscode").lazy_load() -- lazy loads snippets from VS-Code compatible snippets

  --vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" }) -- sets foreground color for Co-Piolot
  vim.api.nvim_set_hl(0, "CmpItemKindTabnine", { fg = "#CA42F0" })
  vim.api.nvim_set_hl(0, "CmpItemKindEmoji", { fg = "#FDE030" })
-- Defines a function to check if the character before the cursor is a space or if the cursor is at the beginning of the line.
--So clicking tab will take you into next piece of snippet while navigating snippet. Does more than that but enables powerful intuitive features.
  local check_backspace = function()
    local col = vim.fn.col "."-1 -- Gets the cursor's column position in the current line and subtracts one to check the character before the cursor. 
    return col == 0 or vim.fn.getline("."):sub(col, col):match "%s" --True if cursor is at start of the line (col == 0) or the character before cursor is a whitespace (match "%s"). 
  end

-- Above function check is commonly used in autocompletion setups to decide whether to show completions or expand snippets based on the context at the cursor position.

  local icons = require "user.core.icons"

  cmp.setup {-- configures nvim-cmp to use LuaSnip for snippet expansion
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body) -- For `luasnip` users.
      end,
    },
    mapping = cmp.mapping.preset.insert { -- assigns below actions to keyboard
      ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }), -- navigating drop-down menu
      ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
      ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
      ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
      ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }), -- enables scrolling of menu
      ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
      ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }), -- see all comletions without typing
      ["<C-e>"] = cmp.mapping {
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      },
      -- Accept currently selected item. If none selected, `select` first item.
      -- Set `select` to `false` to only confirm explicitly selected items.
      ["<CR>"] = cmp.mapping.confirm { select = true }, -- confirm selection and make window disapear
      ["<Tab>"] = cmp.mapping(function(fallback) -- super tab power
        if cmp.visible() then
          cmp.select_next_item() -- if menu is visible then select next item in menu
        elseif luasnip.expandable() then -- if a snippet is expandable then expand it
          luasnip.expand()
        elseif luasnip.expand_or_jumpable() then -- if also jumpable, then jump
          luasnip.expand_or_jump()
        elseif check_backspace() then -- make backspace like a tab to go backwards
          fallback()
          -- require("neotab").tabout()
        else
          fallback()
          -- require("neotab").tabout()
        end
      end, { -- makes mappings usable in the insert and select mode
        "i",
        "s",
      }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
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
    formatting = { -- how should completion items be displayed
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        vim_item.kind = icons.kind[vim_item.kind]
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          nvim_lua = "LUA]",
          luasnip = "[LuaSnip",
          buffer = "[File]",
          path = "[Path]",
          emoji = "[Emoji]",
        })[entry.source.name]

        if entry.source.name == "emoji" then
          vim_item.kind = icons.misc.Smiley
          vim_item.kind_hl_group = "CmpItemKindEmoji"
        end

        if entry.source.name == "cmp_tabnine" then
          vim_item.kind = icons.misc.Robot
          vim_item.kind_hl_group = "CmpItemKindTabnine"
        end

        return vim_item
      end,
    },
    sources = { -- Where should completion items come from
      --{ name = "copilot" },
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "cmp_tabnine" },
      { name = "nvim_lua" },
      { name = "buffer" },
      { name = "path" },
      { name = "calc" },
      { name = "emoji" },
    },
    confirm_opts = {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
    window = {
      completion = {
        border = "rounded",
        scrollbar = false,
      },
      documentation = {
        border = "rounded",
      },
    },
    experimental = {
      ghost_text = false,
    },
  }
end

return M
