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

1. **`<S-h>` / `<S-l>` are mapped twice in `keymaps.lua`.** First to `:bprevious`/`:bnext`, later to
   `^`/`g_`; the later mapping wins, so buffer cycling on those keys is dead. HOTKEYS.md lists both.
   Pick one meaning (e.g. buffers on `[b`/`]b`, which 0.11+ ships by default).
2. **Delete `lua/user/plugins/old_lspconfig.lua`.** Not imported anywhere and uses removed APIs
   (`vim.lsp.with`, `wk.register`, `neodev`, `vim.diagnostic.goto_*`).
3. **Delete or fix `lua/user/core/colorscheme.lua`.** Not required anywhere, and it runs
   `colorscheme colorscheme tokyonight-night` (doubled word), which would fail.
4. **README "What is still useful on Neovim 0.11?" section is stale.** It says which-key,
   telescope, comment, none-ls aren't imported (they are) and that Neovim has no `gc` commenting
   (it has since 0.10). Also has leftover `【F:…】` citation artifacts.
5. **`mason.lua` header comment** describes mason-lspconfig v1 (setup hooks, `:LspInstall`).
6. **`options.lua` + `cmp.lua` both set `completeopt`** (cmp's wins). Also `hidden`,
   `autoindent`, `ruler=false` re-set things that are already defaults or irrelevant.
7. **lualine `extensions = { "fugitive" }`** — fugitive isn't installed.

### LSP

8. **Diagnostics config is gone.** `old_lspconfig.lua` had `vim.diagnostic.config` (sign icons,
   rounded float, severity sort) but nothing loads it now, so you get the defaults. Port it:
   use `signs = { text = { [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error, ... } }`
   (`:sign-define` no longer works in 0.12) and `jump = { on_jump = ... }` instead of `float`.
9. **LSP keymaps.** 0.11+ ships defaults: `grn` rename, `gra` code action, `grr` references,
   `gri` implementation, `grt` type definition, `grx` codelens, `gO` symbols, `K` hover,
   `<C-s>` signature help, `[d`/`]d` diagnostics. The old `gd`, `gl`, `<leader>l*` set isn't
   loaded anywhere — decide which to restore and add them to HOTKEYS.md.
10. **`vim.o.winborder = "rounded"`** (0.11+) gives rounded borders to hover/signature/diagnostic
    floats in one line. Check it doesn't double up on plugins that draw their own borders.
11. **lua_ls library duplication.** `lspsettings/lua_ls.lua` adds all of `$VIMRUNTIME/lua` to
    `workspace.library` while lazydev.nvim already does this on demand — dropping it should make
    lua_ls start faster.
12. **biome twice.** Mason's biome LSP attaches (diagnostics) and none-ls also runs biome
    (formatting). Either let the biome LSP format too and drop the none-ls source, or exclude biome
    from `automatic_enable`.

### Plugin swaps / rewrites (bigger)

13. **indent-blankline is pinned to a 2023 v2 commit.** Works today, but v3 (`ibl`) is the
    maintained version with a different config. Alternative: `snacks.indent`.
14. **none-ls → conform.nvim (formatting) + nvim-lint (linting).** none-ls works, but conform is
    the common modern choice and doesn't fake an LSP client.
15. **Comment.nvim → built-in `gc`/`gcc`** (0.10+, already injection-aware). Keep
    nvim-ts-context-commentstring for JSX/Vue via its own autocmd (`enable_autocmd = true`).
16. **nvim-cmp → blink.cmp, or built-in completion** (`'autocomplete'` + `vim.lsp.completion.enable`,
    `'pumborder'` in 0.12). The native route is lighter but has fewer sources (no emoji/buffer mix).
17. **dressing.nvim is archived** (only pulled in by nerdy.nvim). telescope-ui-select already
    handles `vim.ui.select`; check if nerdy still needs it.
18. **Treesitter folding**: set `foldmethod = "expr"`, `foldexpr = "v:lua.vim.treesitter.foldexpr()"`
    (and maybe `foldlevel = 99`) — the old comment in `options.lua` now points at the right expr.
19. **nvim-treesitter-textobjects (main branch)** for `af`/`if`/`ac`/`ic` style text objects.
20. **ui2** (experimental in 0.12): `require('vim._core.ui2').enable()` replaces the message area,
    removes "Press ENTER" prompts, highlights the cmdline as you type. Could make nvim-notify
    unnecessary. Try once it's no longer experimental.
21. **`vim.pack`** — 0.12's built-in plugin manager. Not worth leaving lazy.nvim for right now
    (no lazy-loading, no lockfile UI), but worth watching.

### Startup noise

22. **"Sessions list is empty"** notification on every launch outside a project, from
    neovim-session-manager (`last_session_on_startup = true`).
23. **Tip.nvim**: re-enable in `plugins/tip.lua` when
    `curl -s -o /dev/null -w '%{http_code}' https://vtip.43z.one` returns 200.
