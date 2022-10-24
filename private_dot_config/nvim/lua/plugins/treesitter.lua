-----------------------------------
-- Treesitter configuration file --
-----------------------------------

-- Plugin: nvim-treesitter
-- url: https://github.com/nvim-treesitter/nvim-treesitter


local status_ok, configs = pcall(require, 'nvim-treesitter.configs')
if not status_ok then
  return
end

-- See: https://github.com/nvim-treesitter/nvim-treesitter#quickstart
configs.setup({
	ensure_installed = {"cmake" ,"c", "cpp", "bash", "fish", "css", "cuda", "dockerfile", "graphql",
        "html", "json", "latex", "llvm", "lua", "markdown", "python", "r", "regex", "sql",
        "typescript", "vim", "vue", "yaml"}, -- one of "all" or a list of languages
	ignore_install = { "" }, -- List of parsers to ignore installing
	highlight = {
		enable = true, -- false will disable the whole extension
		disable = {""}, -- list of language that will be disabled
	},
	autopairs = {
		enable = true,
	},
	indent = { enable = true },
  rainbow = {
    enable = true,
    -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
    -- colors = {}, -- table of hex strings
    -- termcolors = {} -- table of colour name strings
    -- Setting colors
    colors = {
      -- Colors here
    },
    -- Term colors
    termcolors = {
      -- Term colors here
    }
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
})
