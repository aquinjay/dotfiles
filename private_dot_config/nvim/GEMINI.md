# Neovim Configuration Rules (`~/.config/nvim`)

This workspace is the user's live Neovim configuration on Linux (**NVIM v0.12.6**), tracked by **chezmoi** (managed under `private_dot_config/nvim`).

## Chezmoi Workflow (Required)

- Edit files directly in `~/.config/nvim/`.
- After testing changes, sync them back to chezmoi:
  - Modified tracked files: `chezmoi re-add <path>` (or `chezmoi re-add ~/.config/nvim`).
  - Newly created files: `chezmoi add <path>` (so chezmoi starts tracking them).
  - Removed files: remove from chezmoi source with `chezmoi forget <path>` or `chezmoi destroy` only when explicitly confirmed.
- Track `lazy-lock.json` in chezmoi after plugin installs/updates so installations remain reproducible.
- Never add temporary/cache files or `.git` artifacts to chezmoi.
- Finish every config change by checking `chezmoi status` for `~/.config/nvim` to verify there is no drift.

## Architecture & Neovim 0.12 Conventions

- **Entrypoint & plugin registration**: `init.lua` loads `lua/user/core/*`, registers every plugin via `lazy_helper.spec "user.plugins.<name>"`, and ends with `require "user.lazy_init"`. Always register new plugin files in `init.lua`.
- **Core modules**: General options live in `lua/user/core/options.lua`, global keymaps in `lua/user/core/keymaps.lua`, and agent/external-reload helpers in `lua/user/core/agent.lua`.
- **LSP (0.11+/0.12 native API)**:
  - Use `vim.lsp.config("<server>", ...)` and `vim.lsp.enable(...)` in `lua/user/plugins/lspconfig.lua`, with per-server settings in `lua/user/plugins/lspsettings/<server>.lua`.
  - Never use the legacy `require("lspconfig").<server>.setup()` API or `util.root_pattern(...)`.
  - Use `client:supports_method(...)` (colon syntax), `vim.diagnostic.jump(...)` (not `goto_next`/`goto_prev`), and `vim.diagnostic.config({ signs = { text = { ... } } })` (not `:sign-define`).
  - Remember `mason-lspconfig` v2 auto-enables every Mason-installed server; use `automatic_enable.exclude` in `lua/user/plugins/mason.lua` to prevent duplicates (e.g. `pyright` is excluded in favor of `basedpyright`).
- **Treesitter (`main` branch)**: `lua/user/plugins/treesitter.lua` uses `nvim-treesitter` (`branch = "main"`) purely for parser/query installation and calls Neovim's native `vim.treesitter.start()`. Do not re-introduce legacy `nvim-treesitter.configs`.
- **Other 0.12 APIs**: Prefer `vim.uv` over `vim.loop`, `vim.hl.on_yank` over `vim.highlight.on_yank`, and `vim.fs.joinpath` over `lspconfig.util.path.join`.
- **Keymaps & UI consistency**:
  - Leader key is `<Space>`. Reserve `<leader>a` for Tabs, `<leader>b` for Buffers, `<leader>c` for Agent/Context, `<leader>d` for Debug, `<leader>f` for Find, `<leader>g` for Git, `<leader>l` for LSP, `<leader>m` for CMake/Build, `<leader>n` for Obsidian Notes, `<leader>o` for Explorer, `<leader>p` for Project, `<leader>t` for Test, `<leader>T` for Treesitter, `<leader>x` for Diagnostics (Trouble).
  - Keep `lua/user/plugins/whichkey.lua`, `HOTKEYS.md`, and `WORKFLOWS.md` updated whenever keymaps or major workflows change.
  - When adding plugins with custom UI/drawer filetypes, add those filetypes to `disabled_filetypes` in `lua/user/plugins/hardtime.lua`.
  - Preserve rounded borders (`winborder = "rounded"` and `border = "rounded"` on plugin windows) and shared icons from `lua/user/core/icons.lua`.
- **Formatting & Linting**: Formatting is handled manually via `conform.nvim` (`<leader>lf`); **format-on-save is intentionally disabled** — do not re-enable `format_on_save` unless explicitly asked. Linting for Fish runs via `nvim-lint` (`fish -n`), Bash via `bashls` + `shellcheck`, Python via `ruff`, and C++ via `clangd --clang-tidy`.
- **Obsidian vaults**: Do not break `lua/user/core/vaults.lua`, `lua/user/plugins/obsidian.lua`, `lua/user/plugins/render-markdown.lua`, or `after/ftplugin/markdown.lua` (e.g., avoid global `gd`/`<CR>` overrides that shadow vault buffer-local mappings).

## Verification Before Finishing

- Always test configuration changes headlessly before syncing to chezmoi:
  - Verify Neovim loads cleanly without Lua errors (`nvim --headless "+qa"` and check stderr / `v:errmsg`).
  - When adding plugins, install/sync via `:Lazy! sync` (headless) and verify each new plugin module loads cleanly.
  - Run Lua syntax checks (`luac` or `nvim --headless` `loadfile`) on all modified `.lua` files.

## Implemented Capability Stack

All planned phases are live and documented in `WORKFLOWS.md` and `HOTKEYS.md`:
- **Agent integration**: `autoread`/`checktime`, persistent `<M-a>`/`<leader>ca` `agy` split terminal (`q` hides, `/exit` auto-closes), `<leader>c*` clipboard/send helpers, and `codecompanion.nvim` (`agy acp`).
- **Git & Diagnostics**: `gitsigns.nvim`, `diffview.nvim`, `trouble.nvim`, and Neovim 0.12 native `vim.diagnostic.config`.
- **Languages**: Python (`basedpyright` + `ruff` + `venv-selector` + `debugpy` + `pytest`), Bash (`bashls` + `shellcheck` + `shfmt`), Fish (`fish_lsp` + `fish -n` + `fish_indent`), C/C++ (system `clangd` + `clangd_extensions` + `clang-format` + `neocmakelsp` + `cmake-tools.nvim` + native GDB DAP + `neotest-gtest`), and `nvim-treesitter-textobjects`.
- **Dotfiles**: `chezmoi.nvim` (`<leader>fc`, `<leader>pc`, auto-watch in `~/.local/share/chezmoi`).
