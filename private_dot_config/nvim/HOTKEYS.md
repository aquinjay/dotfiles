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
| Chezmoi dotfiles | `<leader>fc` | Pick any chezmoi-managed file |
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
| Next / previous buffer | `]b` / `[b` | Built-in (0.11+) |
| Alternate buffer | `<M-Tab>` | Same as `<C-6>` |
| New empty tab | `<leader>an` | Opens new tab |
| Open current file in new tab | `<leader>aN` | Tab from current file |
| Close other tabs | `<leader>ao` | Tab only |
| Move tab left | `<leader>ah` |  |
| Move tab right | `<leader>al` |  |
| Terminal tab | `<leader>;` | Opens terminal in new tab |
| CD to current file directory | `<leader>pd` | Sets cwd to current buffer dir |
| Chezmoi re-add current file | `<leader>pc` | Syncs current live file back to chezmoi |

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
| Start syntax selection | `<CR>` | normal |
| Increase syntax selection | `<CR>` or `an` | visual |
| Shrink syntax selection | `<BS>` or `in` | visual |
| Select next / previous node | `]n` / `[n` | visual |
| Extend selection to next / previous node | `]N` / `[N` | visual |
| Select outer / inner function | `af` / `if` | visual / operator |
| Select outer / inner class | `ac` / `ic` | visual / operator |
| Select outer / inner argument | `aa` / `ia` | visual / operator |
| Next / prev function start | `]m` / `[m` | normal / visual / operator |
| Next / prev function end | `]M` / `[M` | normal / visual / operator |
| Next / prev class start | `]]` / `[[` | normal / visual / operator |
| Update parsers | `:TSUpdate` | command |

`an`, `in`, `]n`, `[n`, `]N` and `[N` are built into Neovim 0.12 (`:h treesitter-incremental-selection`). The old `<S-CR>` "grow to scope" has no built-in equivalent and was dropped.

## LSP

| Goal | Key / Command | Mode | Notes |
|---|---:|---:|---|
| Go to definition | `gd` | normal | Buffer-local on LSP attach |
| Go to declaration | `gD` | normal | Useful for C/C++ headers |
| Go to implementation | `gI` or `gri` | normal | `gri` is built-in (0.11+) |
| Hover docs | `K` | normal | Built-in; rounded border |
| References | `grr` | normal | Built-in |
| Type definition | `grt` | normal | Built-in |
| Line diagnostics float | `gl` | normal | Also opens on `[d`/`]d` jump |
| Next / prev diagnostic | `<leader>lj` / `<leader>lk` or `]d` / `[d` | normal | Opens diagnostic float |
| Code action | `<leader>la` or `gra` | normal / visual | Uses Telescope UI-Select |
| Rename symbol | `<leader>lr` or `grn` | normal |  |
| Format buffer / selection | `<leader>lf` | normal / visual | `conform.nvim` (manual only; no format-on-save) |
| Run linter | `<leader>lL` | normal | `nvim-lint` (`fish -n`) |
| Switch C/C++ source / header | `<leader>lc` | normal | Buffer-local when `clangd` attaches |
| Select Python virtual env | `<leader>lv` | normal | Python buffers (`venv-selector.nvim`) |
| Run CodeLens | `<leader>ll` or `grx` | normal |  |
| Document / workspace symbols | `<leader>ls` / `<leader>lS` | normal | Telescope pickers (`gO` built-in) |
| Diagnostics to loclist | `<leader>lq` | normal |  |
| LSP info / health | `<leader>li` | normal | `:checkhealth vim.lsp` |
| Toggle inlay hints | `<leader>lh` | normal | Per buffer |
| Toggle diagnostic virtual text | `<leader>ld` | normal | Global toggle (off by default) |
| Manage clients (restart/stop) | `:lsp` | command | Built-in (0.12) |

## Diagnostics & Lists (Trouble)

| Goal | Key | Notes |
|---|---:|---|
| Workspace diagnostics | `<leader>xx` | Toggle Trouble drawer |
| Buffer diagnostics | `<leader>xX` | Current buffer only |
| Document symbols | `<leader>xs` | Side panel |
| LSP defs / refs | `<leader>xl` | Right panel |
| Location list | `<leader>xL` | Toggle Trouble loclist |
| Quickfix list | `<leader>xq` | Toggle Trouble quickfix |

## Git (Gitsigns & Diffview)

| Goal | Key | Mode | Notes |
|---|---:|---:|---|
| Next / previous hunk | `]c` / `[c` | normal | Preserves default diff nav in diff mode |
| Preview hunk | `<leader>gp` | normal | Rounded floating preview |
| Stage hunk | `<leader>gs` | normal / visual | Stage hunk or visual lines |
| Reset hunk | `<leader>gr` | normal / visual | Revert unwanted edits hunk-by-hunk |
| Stage / reset buffer | `<leader>gS` / `<leader>gR` | normal | Whole file |
| Blame line | `<leader>gb` | normal | Full commit blame popup |
| Toggle inline blame | `<leader>gB` | normal | Virtual text blame |
| Diff current file | `<leader>gD` | normal | Gitsigns split diff |
| Repo diff view | `<leader>gd` | normal | `:DiffviewOpen` multi-file review |
| File / repo git history | `<leader>gh` / `<leader>gH` | normal | `:DiffviewFileHistory` |
| Close diff view | `<leader>gx` | normal | `:DiffviewClose` |
| Select git hunk text object | `ih` | operator / visual | e.g. `dih`, `vih` |

## Agent & CodeCompanion (`agy`)

Buffers modified on disk by external agents automatically reload (`autoread` + `checktime`). See [WORKFLOWS.md](./WORKFLOWS.md) for full end-to-end guides.

| Goal | Key | Mode | Notes |
|---|---:|---:|---|
| Toggle `agy` split terminal | `<M-a>` or `<leader>ca` | normal / terminal (`<M-a>`) | Persistent right split (`q` hides in Normal mode; `/exit` auto-closes) |
| Toggle `agy --continue` | `<leader>cC` | normal | Resume last CLI session |
| Send `@file:line` / range to `agy` | `<leader>cp` | normal / visual | Inserts reference into `agy` terminal |
| Toggle CodeCompanion chat | `<leader>cc` | normal / visual | Native buffer backed by `agy acp` |
| CodeCompanion actions | `<leader>cA` | normal / visual | Action palette |
| CodeCompanion inline prompt | `<leader>ci` | normal / visual | In-buffer edit/prompt |
| Add selection to chat | `<leader>cx` | visual | Sends visual range to CodeCompanion |
| Copy `@file:L<line>` / range | `<leader>cy` | normal / visual | Copies to `+` clipboard |
| Copy fenced snippet + `@file:lines` | `<leader>cs` | visual | Includes filetype code fence |
| Copy `@file` path | `<leader>cf` | normal | Relative to cwd |
| Copy buffer diagnostics | `<leader>cd` | normal | Formatted list for pasting to `agy` |
| Copy workspace diagnostics | `<leader>cD` | normal | All loaded buffers, grouped by file |

## Debugging (`nvim-dap` + `nvim-dap-view`)

Python uses Mason `debugpy`; C/C++ uses native system `gdb --interpreter=dap`.

| Goal | Key | Mode | Notes |
|---|---:|---:|---|
| Toggle breakpoint | `<leader>db` | normal |  |
| Conditional breakpoint | `<leader>dB` | normal | Prompts for condition |
| Start / continue | `<leader>dc` or `<F5>` | normal | Auto-opens `dap-view` |
| Step over | `<leader>do` or `<F10>` | normal |  |
| Step into | `<leader>di` or `<F11>` | normal |  |
| Step out | `<leader>dO` or `<F12>` | normal |  |
| Run to cursor | `<leader>dC` | normal |  |
| Terminate session | `<leader>dt` | normal | Auto-closes `dap-view` |
| Run last debug config | `<leader>dl` | normal |  |
| Toggle DAP view | `<leader>du` | normal | Scopes, watches, breakpoints, threads, REPL, console |
| Watch expression | `<leader>dw` | normal / visual | Adds symbol/selection to watches |
| Toggle DAP REPL | `<leader>dr` | normal |  |

## Testing (`neotest`)

Supports Python (`pytest`) and C++ GoogleTest (`:ConfigureGtest` once per C++ project).

| Goal | Key | Notes |
|---|---:|---|
| Run nearest test | `<leader>tt` | Under cursor |
| Run test file | `<leader>tf` | Current file |
| Run all tests | `<leader>ta` | Whole workspace |
| Debug nearest test | `<leader>td` | Launches under `nvim-dap` |
| Toggle test summary | `<leader>ts` | Side tree view |
| Show test output float | `<leader>to` | Enters float; auto-closes |
| Toggle test output panel | `<leader>tO` | Persistent bottom panel |
| Stop running tests | `<leader>tS` |  |
| Toggle watch mode | `<leader>tw` | Re-runs current file on save |
| Next / prev failed test | `]t` / `[t` |  |

## CMake / Build (`cmake-tools.nvim`)

Auto-loads when `CMakeLists.txt` is in cwd and symlinks `compile_commands.json` to project root.

| Goal | Key | Notes |
|---|---:|---|
| Generate CMake | `<leader>mg` | Exports + symlinks `compile_commands.json` |
| Build target | `<leader>mb` |  |
| Run launch target | `<leader>mr` |  |
| Debug target (GDB DAP) | `<leader>md` | Launches inside `nvim-dap` |
| Select build target | `<leader>mt` |  |
| Select launch target | `<leader>ml` |  |
| Select build type | `<leader>mT` | Debug / Release / etc. |
| Clean build | `<leader>mc` |  |

## Notes: Obsidian vaults

`obsidian.nvim` handles the vaults (Thinking, Consulting); `render-markdown.nvim` draws the formatting.
The `<leader>n` keys work from anywhere; the in-note keys work inside vault notes.

| Goal | Key | Notes |
|---|---:|---|
| Find note by name | `<leader>nf` | Picker (Telescope) |
| Search note text | `<leader>ns` | ripgrep across the vault |
| Browse tags | `<leader>nt` |  |
| Today's daily note | `<leader>nd` | Uses Daily Template |
| List daily notes | `<leader>nD` |  |
| New note | `<leader>nn` | Lands in `+ Encounters` |
| New note from template | `<leader>nN` | Pick from `Extras/Templates` |
| Switch vault | `<leader>nw` | Thinking ↔ Consulting |
| **Open current note in Obsidian app** | `<leader>no` | App live-reloads on every save — shows images, Datacore, Excalidraw |
| Backlinks | `<leader>nb` | Or `grr` |
| Links in this note | `<leader>nl` |  |
| Table of contents | `<leader>nc` |  |
| Insert template | `<leader>ni` |  |
| Rename note + update links | `<leader>nr` | Or `grn`; then `:wa` |
| Paste image from clipboard | `<leader>np` | Saves to `Extras/` |
| Toggle rendered / raw markdown | `<leader>nm` | Any markdown file |
| Follow link / toggle checkbox / fold heading | `<CR>` | In vault notes (replaces syntax selection there) |
| Next / previous link | `]o` / `[o` | In vault notes |
| Go to linked note | `gd` | In vault notes |
| Complete `[[note]]`, `[[##heading]]`, `#tag`, `> [!callout` | type it | Completion menu |
| Fold / unfold section | `za` / `zc` / `zo` | `zM` close all, `zR` open all |

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
| Check LSP | `:checkhealth vim.lsp` (or `:LspInfo`) | Active language servers |
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
