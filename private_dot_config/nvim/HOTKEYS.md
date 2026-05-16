# Neovim Hotkey Reference

This file is the human-facing map for your Neovim workflow. It is organized by what you are trying to do, not by plugin.

Leader key: `<Space>`

## Daily workflow

| Goal | Key | Notes |
|---|---:|---|
| Open Neovim in a project | `nvim .` | Starts in the current directory |
| Open file explorer | `<leader>oe` | Toggles Neo-tree on the left |
| Reveal current file | `<leader>of` | Shows current buffer inside Neo-tree |
| Find file | `<leader>ff` | Telescope file picker |
| Search text | `<leader>ft` | Telescope live grep / ripgrep |
| Recent files | `<leader>fr` | Telescope oldfiles |
| Last Telescope search | `<leader>fl` | Resume previous Telescope picker |
| Open buffers | `<leader>bb` | Telescope buffer picker |
| Project picker | `<leader>pp` | neovim-project history |
| Clear search highlight | `<leader>h` | Removes search highlighting |
| Toggle word wrap | `<leader>w` | Useful for prose / markdown |
| Quit Neovim | `<leader>q` | Confirm before quitting |

## File explorer: Neo-tree

Open with `<leader>oe` or reveal current file with `<leader>of`.

| Goal | Key | Notes |
|---|---:|---|
| Open file/folder | `<Enter>` or `l` | Opens files, expands folders |
| Close folder | `h` | Closes current node |
| Toggle folder | `<Space>` | Expands/collapses node |
| Add file/folder | `a` | Relative to selected path |
| Delete | `d` | Deletes selected file/folder |
| Rename | `r` | Renames selected item |
| Copy | `y` | Copies selected item |
| Paste | `p` | Pastes copied item |
| Refresh | `<C-r>` | Refresh tree |
| Close explorer | `q` | Closes Neo-tree window |

## Telescope

| Goal | Key | Notes |
|---|---:|---|
| Find files | `<leader>ff` | Includes hidden files, excludes `.git` |
| Search text | `<leader>ft` | Uses ripgrep |
| Help docs | `<leader>fh` | Search help tags |
| Resume picker | `<leader>fl` | Last Telescope picker |
| Recent files | `<leader>fr` | Recently opened files |
| Git branches | `<leader>fgb` | Checkout branch picker |
| Buffers | `<leader>bb` | Open/delete buffers |

Inside Telescope:

| Goal | Insert mode | Normal mode |
|---|---:|---:|
| Move down | `<C-j>` | `j` |
| Move up | `<C-k>` | `k` |
| History next | `<C-n>` | — |
| History previous | `<C-p>` | — |
| Close picker | — | `q` or `<Esc>` |

## Windows, splits, buffers, tabs

| Goal | Key | Notes |
|---|---:|---|
| Move left window | `<C-h>` or `<M-h>` | Ctrl/Alt variants both exist |
| Move down window | `<C-j>` or `<M-j>` |  |
| Move up window | `<C-k>` or `<M-k>` |  |
| Move right window | `<C-l>` or `<M-l>` |  |
| Vertical split | `<leader>v` | Creates vsplit |
| Next buffer | `<S-l>` | Buffer next |
| Previous buffer | `<S-h>` | Buffer previous |
| Alternate buffer | `<M-Tab>` | Same as `<C-6>` |
| New empty tab | `<leader>an` | Opens new tab |
| Open current file in new tab | `<leader>aN` | Tab from current file |
| Close other tabs | `<leader>ao` | Tab only |
| Move tab left | `<leader>ah` |  |
| Move tab right | `<leader>al` |  |
| Terminal tab | `<leader>;` | Opens terminal in new tab |
| CD to current file directory | `<leader>pd` | Sets cwd to current buffer dir |

## Editing and movement

| Goal | Key | Mode |
|---|---:|---|
| Move to first non-blank character | `<S-h>` | normal/operator/visual |
| Move to last non-blank character | `<S-l>` | normal/operator/visual |
| Keep search result centered | `n`, `N`, `*`, `#`, `g*`, `g#` | normal |
| Visual indent left | `<` | visual |
| Visual indent right | `>` | visual |
| Move visual selection down | `<A-j>` | visual |
| Move visual selection up | `<A-k>` | visual |
| Move visual block down | `J` or `<A-j>` | visual block |
| Move visual block up | `K` or `<A-k>` | visual block |
| Paste without replacing clipboard | `p` | visual / visual block |
| Move by wrapped display line down | `j` | normal / visual |
| Move by wrapped display line up | `k` | normal / visual |

## Completion: nvim-cmp

| Goal | Key | Mode |
|---|---:|---|
| Next completion item | `<C-j>` or `<Tab>` | insert |
| Previous completion item | `<C-k>` or `<S-Tab>` | insert |
| Scroll docs up | `<C-b>` | insert |
| Scroll docs down | `<C-f>` | insert |
| Manually trigger completion | `<C-Space>` | insert |
| Abort completion | `<C-e>` | insert |
| Confirm completion | `<CR>` | insert |
| Toggle completion globally | `:CmpToggle` | command |

## Treesitter

| Goal | Key | Mode |
|---|---:|---|
| Start/increase syntax selection | `<CR>` | visual/select |
| Increase to scope | `<S-CR>` | visual/select |
| Shrink syntax selection | `<BS>` | visual/select |
| Update parsers | `:TSUpdate` | command |

## Illuminated references

`vim-illuminate` highlights other occurrences of the symbol under your cursor.

| Goal | Key | Notes |
|---|---:|---|
| Next highlighted reference | `]r` | Jump forward |
| Previous highlighted reference | `[r` | Jump backward |

## Terminal mode

| Goal | Key | Notes |
|---|---:|---|
| Leave terminal mode | `<C-;>` | Returns to normal mode |
| Move left window | `<C-h>` | From terminal window |
| Move down window | `<C-j>` | From terminal window |
| Move up window | `<C-k>` | From terminal window |
| Move right window | `<C-l>` | From terminal window |

## Right-click / mouse menu

| Goal | Key |
|---|---:|
| Open mouse menu | `<RightMouse>` or `<Tab>` |
| Go to definition | Mouse menu item |
| References | Mouse menu item |

## Discovery tools

| Goal | Key / Command | Notes |
|---|---:|---|
| Show leader-key menu | `<leader>` then pause | Which-key popup |
| Inspect active keymaps | `:map` | Built-in Vim map list |
| Inspect normal maps | `:nmap` | Normal mode only |
| Inspect plugin status | `:Lazy` | Plugin manager |
| Check LSP | `:LspInfo` | Active language servers |
| Check Treesitter | `:checkhealth nvim-treesitter` | Parser/plugin health |

## Suggested muscle-memory path

Start with these only:

1. `<leader>ff` — find file
2. `<leader>ft` — search text
3. `<leader>oe` — open explorer
4. `<leader>of` — reveal current file
5. `<leader>bb` — switch buffers
6. `<C-h/j/k/l>` — move between windows
7. `<leader>pp` — switch projects

Once those are automatic, add tabs, Treesitter selection, and reference jumps.
