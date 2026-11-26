# Neovim 0.12 upgrade notes

Reference for the 0.12 migration (done 2026-11-03 on NVIM v0.12.6) and a backlog of
rewrites we deliberately left for later. Release notes: `:h news`, deprecations: `:h deprecated-0.12`.

## What changed on 2026-11-03

### Fixes (things that were broken)

| Problem | Cause | Fix |
|---|---|---|
| `attempt to call method 'range' (a nil value)` when opening Markdown | nvim-treesitter's frozen `master` branch registers query directives with the `all = false` option, which 0.12 removed. Its `set-lang-from-info-string!` directive then receives a list of nodes instead of one node. | Moved to the `main` branch rewrite (`treesitter.lua`). Needs `tree-sitter-cli` (pacman) + a C compiler. Parsers now live in `~/.local/share/nvim/site/`. |
| LSP never attached for `lua_ls`, `vtsls`, `vue_ls` (silently) | `root_dir = util.root_pattern(...)` is the old lspconfig signature; `vim.lsp.config` calls `root_dir(bufnr, on_dir)`, so the server never got a root and never started. | `lspconfig.lua` now only layers settings on top of nvim-lspconfig's `lsp/<name>.lua` defaults and calls `vim.lsp.enable` once (no FileType autocmds). |
| Inlay hints never showed | `vim.lsp.inlay_hint(bufnr, true)` is a 0.10-nightly signature, wrapped in `pcall` so it failed silently. | `LspAttach` autocmd with `vim.lsp.inlay_hint.enable(true, { bufnr })`, plus `<leader>lh` toggle. |
| pyright **and** basedpyright both attached to Python files | mason-lspconfig v2 `automatic_enable` starts every installed server. | `automatic_enable = { exclude = { "pyright" } }`; basedpyright + ruff are the Python servers. |
| Vue `<script>` TypeScript features | vue_ls v3 forwards TS work to vtsls, which needs `@vue/typescript-plugin` loaded. | Added `vtsls.tsserver.globalPlugins` in `lspsettings/vtsls.lua` (path from Mason's vue-language-server package). |
| Startup "tip" was a raw `502 Bad Gateway` HTML page | vtip.43z.one is down. | Tip.nvim `enabled = false`; nvim-notify split into its own spec so notifications still look the same. |

### API updates (deprecated, still working)

- `vim.highlight.on_yank` → `vim.hl.on_yank` (`keymaps.lua`)
- `client.supports_method(...)` → `client:supports_method(...)` (`none-ls.lua`)
- `vim.loop` → `vim.uv` (`lazy_init.lua`, `alpha.lua`, `treesitter.lua`, `lspsettings/volar.lua`)
- `lspconfig.util.path.join` → `vim.fs.joinpath` (`lspsettings/volar.lua`)
- Dropped the `matchup` module flag (plugin isn't installed; module system no longer exists)
- `lazy.nvim`: `rocks.enabled = false` (no plugin needs luarocks; clears the `:checkhealth lazy` error)

### Behavior to know about

- Incremental selection keeps `<CR>` (start/grow) and `<BS>` (shrink), now backed by 0.12's
  built-in `an`/`in`. `<S-CR>` "grow to scope" has no built-in equivalent and was dropped.
  New built-ins: `]n`/`[n` next/prev node, `]N`/`[N` extend selection.
- 0.12 starts treesitter highlighting for Markdown on its own (ftplugin). The large-file guard
  stops it after the fact, so big `.md` files still skip treesitter.
- The `jsonc` parser was merged into `json` on nvim-treesitter `main`; the jsonc filetype maps to it.
- `:checkhealth vim.lsp` warns about "multiple clients with different position encodings" on
  TS files with a `biome.json`: biome's LSP (auto-enabled by Mason) and vtsls attach together.
  Harmless, see the none-ls item below.

## Backlog: opportunities for later

Roughly ordered by value-for-effort.

### Quick cleanups (small, low risk)

1. **~~`<S-h>` / `<S-l>` are mapped twice in `keymaps.lua`.~~ (Done 2026-11-25)** Removed dead
   `:bprevious`/`:bnext` lines; `<S-h>`/`<S-l>` jump to line ends and built-in `[b`/`]b` cycle buffers.
2. **~~Delete `lua/user/plugins/old_lspconfig.lua`.~~ (Done 2026-11-25)**
3. **~~Delete or fix `lua/user/core/colorscheme.lua`.~~ (Done 2026-11-25)** Deleted unused file.
4. **~~README "What is still useful on Neovim 0.11?" section is stale.~~ (Done 2026-11-25)** Refreshed `README.md`.
5. **~~`mason.lua` header comment~~ (Done 2026-11-25)** Updated for mason-lspconfig v2 + mason-tool-installer.
6. **`options.lua` + `cmp.lua` both set `completeopt`** (cmp's wins). Also `hidden`,
   `autoindent`, `ruler=false` re-set things that are already defaults or irrelevant.
7. **~~lualine `extensions = { "fugitive" }`~~ (Done 2026-11-25)** Switched to `neo-tree`/`lazy`/`mason`/`trouble`, `ignore_focus = { "neo-tree" }`, and relative filename in `lualine_c`.

### LSP

8. **~~Diagnostics config is gone.~~ (Done 2026-11-25)** Restored `vim.diagnostic.config` in
   `lspconfig.lua` with `signs.text`, `severity_sort`, `jump.on_jump` float, rounded float, and
   `<leader>ld` virtual-text toggle; added `trouble.nvim` (`<leader>x*`).
9. **~~LSP keymaps.~~ (Done 2026-11-25)** Restored buffer-local `gd`, `gD`, `gI`, `gl`, and
   `<leader>l*` mappings on `LspAttach` in `lspconfig.lua` alongside 0.11+ defaults, and documented
   them in `HOTKEYS.md`.
10. **~~`vim.o.winborder = "rounded"`~~ (Done 2026-11-25)** Enabled in `options.lua`.
11. **lua_ls library duplication.** `lspsettings/lua_ls.lua` adds all of `$VIMRUNTIME/lua` to
    `workspace.library` while lazydev.nvim already does this on demand — dropping it should make
    lua_ls start faster.
12. **biome twice.** Mason's biome LSP attaches (diagnostics) and none-ls also runs biome
    (formatting). Either let the biome LSP format too and drop the none-ls source, or exclude biome
    from `automatic_enable`.

### Plugin swaps / rewrites (bigger)

13. **indent-blankline is pinned to a 2023 v2 commit.** Works today, but v3 (`ibl`) is the
    maintained version with a different config. Alternative: `snacks.indent`.
14. **~~none-ls → conform.nvim (formatting) + nvim-lint (linting).~~ (Done 2026-11-25)** Replaced
    `none-ls.lua` with `conform.lua` (manual `<leader>lf` only, no format-on-save) and `lint.lua`.
15. **Comment.nvim → built-in `gc`/`gcc`** (0.10+, already injection-aware). Keep
    nvim-ts-context-commentstring for JSX/Vue via its own autocmd (`enable_autocmd = true`).
16. **nvim-cmp → blink.cmp, or built-in completion** (`'autocomplete'` + `vim.lsp.completion.enable`,
    `'pumborder'` in 0.12). The native route is lighter but has fewer sources (no emoji/buffer mix).
17. **dressing.nvim is archived** (only pulled in by nerdy.nvim). telescope-ui-select already
    handles `vim.ui.select`; check if nerdy still needs it.
18. **Treesitter folding**: set `foldmethod = "expr"`, `foldexpr = "v:lua.vim.treesitter.foldexpr()"`
    (and maybe `foldlevel = 99`) — the old comment in `options.lua` now points at the right expr.
19. **~~nvim-treesitter-textobjects (main branch)~~ (Done 2026-11-25)** Added in `treesitter_textobjects.lua`
    (`af`/`if`, `ac`/`ic`, `aa`/`ia`, `]m`/`[m`, `]]`/`[[`).
20. **ui2** (experimental in 0.12): `require('vim._core.ui2').enable()` replaces the message area,
    removes "Press ENTER" prompts, highlights the cmdline as you type. Could make nvim-notify
    unnecessary. Try once it's no longer experimental.
21. **`vim.pack`** — 0.12's built-in plugin manager. Not worth leaving lazy.nvim for right now
    (no lazy-loading, no lockfile UI), but worth watching.

### Obsidian notes (added 2026-11-03 with obsidian.nvim + render-markdown.nvim)

22a. **Hyprland rule for `<leader>no`.** `:Obsidian open` already jumps the app to the current
     note; a window rule could always place Obsidian beside the terminal on the same workspace.
22b. **Inline images.** 343 notes embed images. Alacritty has no Kitty graphics protocol, so
     they can't show inside Neovim. Switching to Kitty/Ghostty/WezTerm would allow
     `snacks.image`/`image.nvim` — a big change given the matugen-themed Alacritty setup.
22c. **Templates are partly Obsidian-only.** Datacore blocks (233 notes) only render in the app.
     `{{date}}`, `{{title}}`, `{{sunday:…}}`, `{{saturday:…}}` and moment `gggg`/`ww` work
     (week numbers verified against all existing daily notes).

### Startup noise

22. **"Sessions list is empty"** notification on every launch outside a project, from
    neovim-session-manager (`last_session_on_startup = true`).
23. **Tip.nvim**: re-enable in `plugins/tip.lua` when
    `curl -s -o /dev/null -w '%{http_code}' https://vtip.43z.one` returns 200.
