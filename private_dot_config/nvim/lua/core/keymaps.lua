-- Remap default keys to custom keys in Neovim

-- General options
local opts = {noremap = true, silent = true} -- All modes and remove echo

-- Terminal options
local term_opts = {silent = true}

-- Shorten remap function name
local keymap =  vim.api.nvim_set_keymap

-- Remap space as the leader key
keymap("", "<Space>", "<Nop>", opts) 
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-----------
-- Modes --
-----------

-- Normal mode = "n"
-- Insert mode = "i"
-- Visual mode = "v"
-- Visual block mode = "x"
-- Terminal mode = "t" 
-- Command mode = "c"

------------
-- Normal --
------------

-- Better window navigation 
-- Replace arg 3 with arg 2
-- C = Ctrl
keymap("n", "<C-h>", "<C-w>h", opts) -- normal, Set to Ctrl+h from Ctrl+w and h
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- <cr> = carriage return = enter key
--
keymap("n", "<leader>e", ":Lex 30<cr>", opts) -- Opens File Explorer. 

-- Resize windows with arrows 
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
-- S = Shift
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

------------
-- Insert --
------------

-- Press jk fast to go back to normal mode
keymap("i", "jk","<ESC>",opts)

------------
-- Visual --
------------

-- Can repeadently indent
keymap("v", "<","<gv",opts)
keymap("v", ">",">gv",opts)

-- Move text up and down
-- A = Alt 
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts) -- Don't copy deleted word when you paste

------------------
-- Visual Block --
------------------

-- Same as above but move entire block. Below not redundent. Need double re-mapping
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

--------------
-- Terminal --
--------------

-- Better terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)
