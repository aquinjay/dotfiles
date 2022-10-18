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
  --use { "numToStr/Comment.nvim", commit = "97a188a98b5a3a6f9b1b850799ac078faa17ab67" }
  --use { "JoosepAlviste/nvim-ts-context-commentstring", commit = "4d3a68c41a53add8804f471fcc49bb398fe8de08" }
  --use { "kyazdani42/nvim-web-devicons", commit = "563f3635c2d8a7be7933b9e547f7c178ba0d4352" }
  --use { "kyazdani42/nvim-tree.lua", commit = "7282f7de8aedf861fe0162a559fc2b214383c51c" }
  --use { "akinsho/bufferline.nvim", commit = "83bf4dc7bff642e145c8b4547aa596803a8b4dc4" }
	--use { "moll/vim-bbye", commit = "25ef93ac5a87526111f43e5110675032dbcacf56" }
  --use { "nvim-lualine/lualine.nvim", commit = "a52f078026b27694d2290e34efa61a6e4a690621" }
  --use { "akinsho/toggleterm.nvim", commit = "2a787c426ef00cb3488c11b14f5dcf892bbd0bda" }
  --use { "ahmedkhalf/project.nvim", commit = "628de7e433dd503e782831fe150bb750e56e55d6" }
  --use { "lewis6991/impatient.nvim", commit = "b842e16ecc1a700f62adb9802f8355b99b52a5a6" }
  --use { "lukas-reineke/indent-blankline.nvim", commit = "db7cbcb40cc00fc5d6074d7569fb37197705e7f6" }
  --use { "goolord/alpha-nvim", commit = "0bb6fc0646bcd1cdb4639737a1cee8d6e08bcc31" }
	--use {"folke/which-key.nvim"}

	-- Colorschemes
  use { "folke/tokyonight.nvim"}
  --use { "lunarvim/darkplus.nvim"}

	-- Cmp 
  use { "hrsh7th/nvim-cmp"} -- The completion plugin
  use { "hrsh7th/cmp-buffer"} -- buffer completions. Buffer is the message definition window that appears when you type
  use { "hrsh7th/cmp-path"} -- path completions
	use { "saadparwaiz1/cmp_luasnip"} -- snippet completions. Snippets are the word completion windows that appear
	use { "hrsh7th/cmp-nvim-lsp"}
	use { "hrsh7th/cmp-nvim-lua"}

	-- Snippets
  use { "L3MON4D3/LuaSnip"} --snippet engine. For snip window above.
  use { "rafamadriz/friendly-snippets"} -- a bunch of snippets to use for many languages.

	-- LSP
	--use { "neovim/nvim-lspconfig", commit = "f11fdff7e8b5b415e5ef1837bdcdd37ea6764dda" } -- enable LSP
  --use { "williamboman/mason.nvim", commit = "c2002d7a6b5a72ba02388548cfaf420b864fbc12"} -- simple to use language server installer
  --use { "williamboman/mason-lspconfig.nvim", commit = "0051870dd728f4988110a1b2d47f4a4510213e31" }
	--use { "jose-elias-alvarez/null-ls.nvim", commit = "c0c19f32b614b3921e17886c541c13a72748d450" } -- for formatters and linters
  --use { "RRethy/vim-illuminate", commit = "a2e8476af3f3e993bb0d6477438aad3096512e42" }

	-- Telescope
	--use { "nvim-telescope/telescope.nvim", commit = "76ea9a898d3307244dce3573392dcf2cc38f340f" }

	-- Treesitter
	--use {"nvim-treesitter/nvim-treesitter",commit = "8e763332b7bf7b3a426fd8707b7f5aa85823a5ac",}

	-- Git
	--use { "lewis6991/gitsigns.nvim", commit = "2c6f96dda47e55fa07052ce2e2141e8367cbaaf2" }

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
