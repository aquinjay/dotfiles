-- :help options
-- :help actual-option-value for specific option help
local options = {
-----------------
---- General ----
-----------------

 fileencoding = "utf-8",                    -- Default encoding written to a file
 clipboard = "unnamedplus",                 -- Allows Neovim to access the system clipboard by default
 mouse = 'a', 		                          -- Enable mouse support
 completeopt = "menuone,noinsert,noselect", -- autocomplete options for easier navigation
 conceallevel = 0,                          -- so that `` is visible in markdown files
 swapfile = false, -- creates a swapfile
 undodir = undodir, -- Set an undo directory
undofile = true, -- enable persistent undo
writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited

-----------------
--- Neovim UI ---
-----------------
number = true, 		                          -- Show row line number
showmatch = true,                           -- Highlight matching parenthesis
foldmethod = 'manual',                      -- Folding, set to "expr" for treesitter based folding
foldexpr = "",                              -- set to "nvim_treesitter#foldexpr()" for treesitter based folding
colorcolumn = '80',                         -- Line length marker at 80 columns
splitright = true,                          -- Vertical split to the right
splitbelow = true,                          -- Horizontal split to the bottom
ignorecase = true,                       	  -- Ignore case letters when search
smartcase = true,       	                  -- Ignore lowercase for the whole pattern
hlsearch = false,                           -- Ignore results of previous search
linebreak = true,                           -- Wrap on word boundary
termguicolors = true,                   	  -- Enable 24-bit RGB colors
laststatus=3,                               -- Set global statusline
showtabline = 2,                            -- Always show tabs
cursorline = true,                          -- Highlight the current line
wrap = true,                               -- Do not display lines as one long line.
cmdheight = 1,                              -- More space for neovim command line for displaying messages
pumheight = 10,                             -- pop up menu height
--showmode = false, -- we don't need to see things like -- INSERT -- anymore
title = true, -- set the title of window to the value of the titlestring
signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
--showcmd = false, -- Hide last command

------------------
-- Tabs, Indent --
------------------

expandtab = true, 	                        -- Use spaces instead of tab
tabstop = 2,		                            -- Insert 2 spaces for a tab
shiftwidth = 2, -- Length of shift, I think
--breakindent = true,                         -- Preserve indentation of virtual lines (connected to wrap)
smartindent = true,                         -- Autoindent new lines
autoindent = true,

-----------------
-- Memory, CPU --
-----------------

hidden = true, -- Enable background buffers
lazyredraw = true, -- Faster scrolling
ruler = false, -- Remove line and column number calcs to display
timeoutlen = 1000, -- time to wait for a mapped sequence to complete (in milliseconds)
updatetime = 100, -- faster completion



}




----------------------------
--  Additional Settings  ---
----------------------------

vim.opt.shortmess:append "c" -- don't show redundant messages from ins-completion-menu
vim.opt.shortmess:append "I" -- don't show the default intro message

for k, v in pairs(options) do
 vim.opt[k] = v
end
