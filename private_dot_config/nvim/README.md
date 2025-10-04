# Neovim Configuration Overview

This Neovim configuration is organized so that startup is predictable and each feature lives in its own module. The following sections explain how the files fit together and what to expect when using the setup.

## Startup Flow
- **`init.lua`** is the only file Neovim reads directly. It loads core options/keymaps, registers the plugin specs that should be installed, and finally runs the Lazy bootstrapper.
- **`lua/user/core/lazy_helper.lua`** keeps a list of plugin imports. Each call to `lazy_helper.spec "user.plugins.some_plugin"` in `init.lua` tells Lazy.nvim to import the plugin definition stored in `lua/user/plugins/some_plugin.lua`.
- **`lua/user/lazy_init.lua`** makes sure [`lazy.nvim`](https://github.com/folke/lazy.nvim) is installed, adds it to Neovim's runtime path, and hands the collected plugin specs to `require("lazy").setup`. The UI is configured to use rounded borders and will automatically install the `tokyonight` colorscheme if it is missing.

## Core Configuration
- **`lua/user/core/options.lua`** sets fundamental editor options (indentation, search behavior, UI tweaks, etc.). Adjust this file for editor-wide behavior.
- **`lua/user/core/keymaps.lua`** defines custom keybindings. Most keymaps are set directly through Lua for clarity and to avoid collision with plugin configs.
- **`lua/user/core/colorscheme.lua`** applies the default theme. Because Lazy ensures `tokyonight.nvim` is present, this file simply sets the colorscheme after plugins are loaded.

## Plugin Specs
Each file in **`lua/user/plugins/`** returns a Lazy plugin specification table. Important examples include:
- `colorscheme.lua` – installs and configures `folke/tokyonight.nvim`.
- `cmp.lua` – configures autocompletion (`nvim-cmp`, `LuaSnip`, and related sources).
- `lspconfig.lua` & `mason.lua` – integrate the LSP client with Mason for easy language-server installs. Mason handles server downloads, while `lspconfig.lua` wires the servers into Neovim when they are available.
- `treesitter.lua` – enables syntax-aware highlighting and text objects.
- `lualine.lua`, `devicons.lua`, `indentline.lua`, `todo_comments.lua`, `hardtime.lua`, etc. – provide UI niceties, productivity helpers, and extra diagnostics.

Some plugin specs (such as `whichkey.lua`, `telescope.lua`, `comment.lua`, and `none-ls.lua`) are present but not currently imported in `init.lua`. To enable them, uncomment the corresponding `lazy_helper.spec` line. The `old_lspconfig.lua` file is kept for reference but is not used.

### What is still useful on Neovim 0.11?

Neovim 0.11 has gained quality-of-life features (built-in inlay hints, `vim.lsp.enable`, `vim.snippet`, etc.), but the core of this configuration still relies on a few plugins for good reason:

| Plugin | Why it is still relevant |
| --- | --- |
| `cmp.lua` | `nvim-cmp` mixes completion from LSP, buffer, snippets, filesystem paths, and even emoji in one menu, while handling custom keymaps and snippet jumps.【F:private_dot_config/nvim/init.lua†L10-L25】【F:private_dot_config/nvim/lua/user/plugins/cmp.lua†L1-L170】|
| `lspconfig.lua` | `nvim-lspconfig` keeps per-server defaults and lets you expand beyond `lua_ls` when you are ready. The comment in `init.lua` notes it “may not be needed,” but removing it would mean managing every server by hand even with the new `vim.lsp.enable` helper.【F:private_dot_config/nvim/init.lua†L17-L18】【F:private_dot_config/nvim/lua/user/plugins/lspconfig.lua†L1-L22】|
| `mason.lua` | Mason still saves you from manually downloading language servers; this spec auto-installs Lua, Python, Bash, and JSON servers with a UI that fits the rest of the setup.【F:private_dot_config/nvim/init.lua†L18】【F:private_dot_config/nvim/lua/user/plugins/mason.lua†L1-L34】|
| `treesitter.lua` | Neovim ships with Tree-sitter runtimes, but the `nvim-treesitter` plugin (configured in `treesitter.lua`) handles parser installation, highlighting, and text objects that the core still lacks.【F:private_dot_config/nvim/init.lua†L21】|
| Comment toggling | Although the comment spec is disabled, Neovim still does not ship a `gc`/`gb` style toggler. If you want motion-based commenting, re-enabling `comment.lua` (and optionally `whichkey.lua`) remains the easiest route.【F:private_dot_config/nvim/init.lua†L16-L25】【F:private_dot_config/nvim/lua/user/plugins/comment.lua†L1-L31】|

Everything else in `init.lua` is cosmetic or workflow sugar: feel free to disable `lualine`, `devicons`, `todo_comments`, `hardtime`, `nerdy`, `illuminate`, or `indentline` when you do not need them—they are not required for Neovim 0.11 itself.【F:private_dot_config/nvim/init.lua†L12-L24】

## LSP, Treesitter, and Tooling
- LSP servers are managed through Mason. Run `:Mason` inside Neovim to install language servers; `lspconfig.lua` automatically registers handlers for installed servers.
- Treesitter parsers are installed and configured via the `treesitter.lua` spec. Use `:TSInstall` to add additional languages if needed.
- Completion, snippets, autopairs, and editor hints work together: `nvim-cmp` surfaces results, `LuaSnip` provides snippet expansion, and other helper plugins polish the UX (e.g., `nvim-autopairs` for bracket pairing and `todo-comments.nvim` for TODO highlighting).

## Extending the Setup
1. Create a new file in `lua/user/plugins/` that returns a Lazy spec for the plugin you want to add.
2. Add `lazy_helper.spec "user.plugins.your_file"` to `init.lua`.
3. Restart Neovim; Lazy.nvim will install the plugin on the next launch.

## Repository Notes
- `lazy-lock.json` records exact plugin commits to keep installations reproducible.
- The `lua/user/lsp/.keep` placeholder keeps the directory tracked even if no explicit files are present yet.

With this structure, most configuration changes can be isolated to a single Lua module, making it easier to maintain and reason about how the Neovim environment behaves.
