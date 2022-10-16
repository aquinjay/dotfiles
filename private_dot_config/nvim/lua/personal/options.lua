-- :help options
-- :help actual-option-value for specific option help
local options = {
-----------------
---- General ----
-----------------

 fileencoding = "utf-8",    -- Default encoding written to a file
 clipboard = "unnamedplus", -- Allows Neovim to access the system clipboard by default
 mouse = 'a', 		  -- Enable mouse support

-----------------
--- Neovim UI ---
-----------------
number = true, 		  -- Show row line number
showmatch = true,          -- Highlight matching parenthesis
foldmethod = 'marker',     -- Enable folding (default 'foldmarker')
--.colorcolumn = '80',      -- Line lenght marker at 80 columns
splitright = true,         -- Vertical split to the right
splitbelow = true,         -- Horizontal split to the bottom
ignorecase = true,      	  -- Ignore case letters when search
smartcase = true,       	  -- Ignore lowercase for the whole pattern
hlsearch = false,          -- Ignore results of previous search
--linebreak = true,        -- Wrap on word boundary
termguicolors = true,   	  -- Enable 24-bit RGB colors
--.laststatus=3            -- Set global statusline
--showtabline = 2, -- Always show tabs
cursorline = true, -- Highlight the current line
wrap = false, -- Do not display lines as one long line.

------------------
-- Tabs, Indent --
------------------

expandtab = true, 	  -- Use spaces instead of tab
tabstop = 2,		  -- Insert 2 spaces for a tab
breakindent = true, -- Preserve indentation of virtual lines (connected to wrap)



-----------------
-- Memory, CPU --
-----------------


}




----------------------------
--  Additional Settings  ---
----------------------------

vim.opt.shortmess:append "c" -- don't show redundant messages from ins-completion-menu
vim.opt.shortmess:append "I" -- don't show the default intro message

for k, v in pairs(options) do
 vim.opt[k] = v
end
