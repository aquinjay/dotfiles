---------------------------------------
-- Plugin manager configuration file --
---------------------------------------

-- Plugin manager: packer.nvim
-- url: https://github.com/wbthomason/packer.nvim

local fn = vim.fn

-- Auto install packer

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"  -- File where plugins go
if fn.empty(fn.glob(install_path)) > 0 then -- If files are not there, then install them using the methods here
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use. Same as packer but if it fails
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	vim.notify("Packer call did not work")
end

-- Have packer use a popup window. 
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- Install your plugins here. Lua plugins are simply GitHub repos with lua directories inside.
-- Below is just cloning github repos 
return packer.startup(function(use)
  -- :Packer then tab to see all commands
  use { "wbthomason/packer.nvim",  -- Your package manager
        } -- Have packer manage itself
  use "nvim-lua/plenary.nvim" -- Useful lua helper functions used by lots of plugins.
  use { "windwp/nvim-autopairs"} -- Autopairs, integrates with both cmp and treesitter
  use { "numToStr/Comment.nvim"} --Easily input regular comment. 
  use { "JoosepAlviste/nvim-ts-context-commentstring"} -- Know which kind of comment string to use based on context of file
  use {"ms-jpq/chadtree", branch = 'chad', run = 'python3 -m chadtree deps'}
  use { "kyazdani42/nvim-web-devicons"}
  --use { "kyazdani42/nvim-tree.lua", commit = "7282f7de8aedf861fe0162a559fc2b214383c51c" } -- repalced by chadtree
  use { "akinsho/bufferline.nvim"}
	use { "moll/vim-bbye"}
  use { "nvim-lualine/lualine.nvim"}
  use { "akinsho/toggleterm.nvim"}
  --use { "ahmedkhalf/project.nvim", commit = "628de7e433dd503e782831fe150bb750e56e55d6" }
  use { "lewis6991/impatient.nvim"}
  --use { "lukas-reineke/indent-blankline.nvim", commit = "db7cbcb40cc00fc5d6074d7569fb37197705e7f6" }
  --use { "goolord/alpha-nvim", commit = "0bb6fc0646bcd1cdb4639737a1cee8d6e08bcc31" }
	use {"folke/which-key.nvim"}

	-- Colorschemes
  use { "folke/tokyonight.nvim"}
  --use { "lunarvim/darkplus.nvim"}

	-- Cmp 
 use { "hrsh7th/nvim-cmp"} -- The completion plugin
 use { "hrsh7th/cmp-buffer"} -- buffer completions. Buffer is the message definition window that appears when you type
 use { "hrsh7th/cmp-path"} -- path completions
 use { "saadparwaiz1/cmp_luasnip"} -- snippet completions. Snippets are the word completion windows that appear 
 use { "hrsh7th/cmp-nvim-lsp"} -- LSP completions

	-- Snippets
  use { "L3MON4D3/LuaSnip"} --snippet engine. For snip window above.
  use { "rafamadriz/friendly-snippets"} -- a bunch of snippets to use for many languages.
  use {"tzachar/cmp-tabnine", run = "./install.sh"}

	-- LSP
	use { "neovim/nvim-lspconfig"} -- enable LSP. Core Neovim
  use { "williamboman/mason.nvim"} -- simple to use language server installer, Next gen nvim-lsp-installer
  use { "williamboman/mason-lspconfig.nvim"}
	use { "jose-elias-alvarez/null-ls.nvim"} -- for formatters and linters. Need to install binaries to get this to work. Linter = Fixer. 
  --use { "RRethy/vim-illuminate", commit = "a2e8476af3f3e993bb0d6477438aad3096512e42" }

	-- Telescope
	use { "nvim-telescope/telescope.nvim", requires = { {'nvim-lua/plenary.nvim'} }
  } -- Super powerfuls fuzzy finder

	-- Treesitter
  use {'nvim-treesitter/nvim-treesitter', -- Syntax highlighting
        }
  use {'p00f/nvim-ts-rainbow'} -- Can see where parenthasis start and end

	-- Git
	use { "lewis6991/gitsigns.nvim"} -- create git indicators in code and provide commands to navigate git 

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
