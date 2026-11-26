# Neovim Configuration Overview

This Neovim configuration targets **NVIM v0.12.6** on Linux and is tracked with **chezmoi** (`private_dot_config/nvim`). Each concern lives in its own module so startup stays fast and predictable.

## Startup Flow
- **`init.lua`** loads core modules (`lua/user/core/*`), registers every plugin spec via `lazy_helper.spec "user.plugins.<name>"`, and calls `require "user.lazy_init"`.
- **`lua/user/core/lazy_helper.lua`** collects plugin imports handed to `lazy.nvim`.
- **`lua/user/lazy_init.lua`** bootstraps [`lazy.nvim`](https://github.com/folke/lazy.nvim) with rounded UI borders and `tokyonight` fallback.

## Core Configuration
- **`lua/user/core/options.lua`** — editor options (`autoread`, `winborder = "rounded"`, `undofile`, indentation, search, UI).
- **`lua/user/core/keymaps.lua`** — global navigation, editing, terminal, and yank-highlight mappings.
- **`lua/user/core/agent.lua`** — external-change auto-reload (`checktime`), toggleable right-split `agy` terminal (`<leader>ca`/`<leader>cC`/`<leader>cp`), and one-keystroke context/diagnostics copy (`<leader>cy`/`<leader>cs`/`<leader>cd`/`<leader>cD`).
- **`lua/user/core/icons.lua`** & **`lua/user/core/vaults.lua`** — shared Nerd Font icons and Obsidian vault paths.

## Plugin Highlights
- **LSP, Formatting & Linting**:
  - `lspconfig.lua` + `lspsettings/*` — native Neovim 0.12 `vim.lsp.config` / `vim.lsp.enable` for `lua_ls`, `vtsls`/`vue_ls`, `basedpyright` + `ruff`, `bashls`, `fish_lsp`, `neocmakelsp`, and system `/usr/bin/clangd`.
  - `mason.lua` — `mason.nvim`, `mason-lspconfig` v2, and `mason-tool-installer.nvim` (`shellcheck`, `shfmt`, `stylua`).
  - `conform.lua` & `lint.lua` — manual formatting (`<leader>lf`, format-on-save intentionally off) via `conform.nvim` (`ruff`, `shfmt`, `fish_indent`, `clang-format`, `stylua`, `biome`) and async linting via `nvim-lint` (`fish -n`).
  - `venv_selector.lua` (`<leader>lv`) & `clangd_extensions.lua` (`<leader>lc` switch source/header + `nvim-cmp` score sorting).
  - `trouble.lua` (`<leader>x*`) — workspace/buffer diagnostics, symbols, references, and quickfix drawer.
- **Debugging, Testing & Build**:
  - `dap.lua` (`<leader>d*`, `<F5>`/`<F10>`/`<F11>`/`<F12>`) — `nvim-dap` + `nvim-dap-view` + `nvim-dap-python` (`debugpy`) and native GDB DAP for C/C++.
  - `neotest.lua` (`<leader>t*`) — inline test runner for Python (`pytest`) and C++ (`neotest-gtest`).
  - `cmake_tools.lua` (`<leader>m*`) — CMake configure/build/run/debug + automatic `compile_commands.json` symlinking.
- **AI Agent Integration**:
  - `codecompanion.lua` (`<leader>cc` / `<leader>cA` / `<leader>ci`) — native Neovim chat & actions wired to Antigravity via `agy acp`.
- **Treesitter**:
  - `treesitter.lua` (`nvim-treesitter` `main` branch + native `vim.treesitter.start()`) & `treesitter_textobjects.lua` (`af`/`if`, `ac`/`ic`, `aa`/`ia`, `]m`/`[m`, `]]`/`[[`).
- **Git, Dotfiles & Navigation**:
  - `gitsigns.lua` (`]c`/`[c`, `<leader>gp`/`<leader>gs`/`<leader>gr`) & `diffview.lua` (`<leader>gd`/`<leader>gh`).
  - `chezmoi.lua` (`<leader>fc`, `<leader>pc`, auto-apply on save in `~/.local/share/chezmoi`).
  - `telescope.lua`, `neo-tree.lua`, `neovim_project.lua`, `whichkey.lua`.
- **Obsidian & Markdown**:
  - `obsidian.lua`, `render-markdown.lua` (also enabled for `codecompanion` buffers), and `after/ftplugin/markdown.lua`.
- **Completion & UI**:
  - `cmp.lua`, `autopairs.lua`, `comment.lua`, `colorscheme.lua`, `lualine.lua`, `alpha.lua`, `indentline.lua`, `illuminate.lua`, `todo_comments.lua`, `hardtime.lua`, `nerdy.lua`.

## Extending the Setup
1. Create a Lazy plugin spec in `lua/user/plugins/<name>.lua`.
2. Register `lazy_helper.spec "user.plugins.<name>"` in `init.lua`.
3. Update `HOTKEYS.md` (and `whichkey.lua` / `hardtime.lua` if adding keymaps or special filetypes).
4. Sync changes with chezmoi (`chezmoi re-add ~/.config/nvim` and `chezmoi add <new-file>`).

## Reference Docs
- **`WORKFLOWS.md`** — step-by-step guides for Antigravity (`agy`), Python, Bash/Fish, C++/CMake, debugging, testing, and chezmoi.
- **`HOTKEYS.md`** — task-oriented keybinding reference.
- **`NVIM-0.12-NOTES.md`** — 0.12 migration history and remaining backlog.
- **`GEMINI.md`** — workspace rules and conventions for Antigravity.
- **`lazy-lock.json`** — pinned plugin commits for reproducible installs.
