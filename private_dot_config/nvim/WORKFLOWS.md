# Neovim Workflows & Capabilities Guide

Task-oriented reference for the coding, debugging, testing, AI agent, and dotfiles capabilities in this Neovim configuration. For a quick keybinding lookup table, see [HOTKEYS.md](./HOTKEYS.md).

---

## 1. Working with Antigravity (`agy`)

You have two complementary ways to drive Antigravity from inside Neovim, plus automatic file reload and Git diff review.

### A. Embedded `agy` Split Terminal (Full CLI TUI)
Best when you want all native `agy` CLI features (slash commands like `/plan`, `/boost`, `/swarm`, approvals, subagents).
- **Toggle open/hide from anywhere (Normal or Terminal mode)**: `<M-a>` (or `<leader>ca` in Normal mode). Hiding keeps your `agy` session running in the background.
- **Resume last CLI conversation**: `<leader>cC` (runs `agy --continue`).
- **Hide from Normal mode inside the split**: press `q`.
- **Quit `agy` completely**: run `/exit` (or `Ctrl+D` twice) — the split automatically closes and cleans up.
- **Send code location straight to `agy`**: place cursor on a line (or visually select a range) and press `<leader>cp` to insert `@relative/path:L<start>-L<end>` directly into the `agy` terminal.

### B. CodeCompanion (`agy acp` — Native Vim Buffer)
Best when you want to draft prompts with full Vim motions and read Markdown responses rendered inline via `render-markdown.nvim`.
- **Toggle chat buffer**: `<leader>cc` (Normal or Visual).
- **Add visual selection to chat**: select lines, then `<leader>cx`.
- **Inline prompt / refactor**: `<leader>ci` (Normal or Visual).
- **Action palette**: `<leader>cA`.
- Uses a custom ACP adapter (`agy acp`) configured in `lua/user/plugins/codecompanion.lua` with `oauth-personal` Google authentication.

### C. Sharing Context & Reviewing Agent Edits
- **Auto-reload**: `autoread` + `checktime` autocmds (`lua/user/core/agent.lua`) automatically reload open unmodified buffers whenever `agy` edits files on disk and display a notification.
- **One-keystroke clipboard copy** (useful if `agy` is open in another terminal window):
  - `<leader>cy` — copy `@relative/path:L<line>` (or visual range)
  - `<leader>cs` — copy visual range as a fenced Markdown block with `@path:lines`
  - `<leader>cf` — copy `@relative/path`
  - `<leader>cd` / `<leader>cD` — copy formatted LSP diagnostics for current buffer / workspace
- **Reviewing changes hunk-by-hunk**:
  - `]c` / `[c` — jump between Git hunks (`gitsigns.nvim`)
  - `<leader>gp` — preview hunk diff inline
  - `<leader>gs` / `<leader>gr` — stage or revert a single hunk (works in Visual mode too)
  - `<leader>gd` — open side-by-side multi-file diff (`DiffviewOpen`) across the whole repo; `<leader>gx` closes it.

---

## 2. Python Workflow

| Capability | Tooling | How to use |
| :--- | :--- | :--- |
| **Type checking & hover** | `basedpyright` (`typeCheckingMode = "standard"`, inlay hints on) | Automatic on `.py` files (`gd`, `K`, `grr`, `<leader>lr`, `<leader>la`) |
| **Linting & code actions** | `ruff` native LSP (hover disabled so `basedpyright` owns `K`) | Automatic; `<leader>la` for quick-fixes, `<leader>xx` for Trouble list |
| **Formatting (manual)** | `conform.nvim` (`ruff_organize_imports` + `ruff_format`) | Press `<leader>lf` (format-on-save is intentionally off) |
| **Virtual envs (`uv`/`.venv`)** | `venv-selector.nvim` | Press `<leader>lv` in a Python file to pick a virtualenv; notifies `basedpyright` |
| **Testing (`pytest`)** | `neotest` + `neotest-python` | `<leader>tt` nearest test, `<leader>tf` file, `<leader>ta` all, `<leader>ts` summary, `<leader>to` output |
| **Debugging (`debugpy`)** | `nvim-dap` + `nvim-dap-python` + `nvim-dap-view` | Set breakpoint `<leader>db`, then `<leader>dc` / `<F5>` to launch or `<leader>td` to debug nearest test |

---

## 3. Bash & Fish Workflow

### Bash / POSIX sh
- **Intelligence & Linting**: `bashls` automatically surfaces **ShellCheck** diagnostics inline (installed via Mason).
- **Formatting (manual)**: `<leader>lf` runs `shfmt` via `conform.nvim`.

### Fish
- **Intelligence**: `fish_lsp` (installed via Mason) provides completions, hover docs on builtins/flags, go-to-definition, and diagnostics.
- **Syntax linting**: `nvim-lint` runs `fish -n` automatically on open/save/insert-leave (`<leader>lL` to re-run manually).
- **Formatting (manual)**: `<leader>lf` runs built-in `fish_indent` via `conform.nvim`.

---

## 4. C / C++ & CMake Workflow

### LSP, Navigation & Formatting
- **Language server**: Uses the host system `/usr/bin/clangd` (`--background-index`, `--clang-tidy`, `--header-insertion=iwyu`, `--completion-style=detailed`) so system compiler and standard library headers match your toolchain.
- **Switch source / header**: `<leader>lc` (`:LspClangdSwitchSourceHeader`) toggles between `.h`/`.hpp` and `.cpp`.
- **Clangd extensions**: Better `nvim-cmp` completion ranking (`clangd_extensions.cmp_scores`) plus `:ClangdAST`, `:ClangdTypeHierarchy`, `:ClangdMemoryUsage`, `:ClangdSymbolInfo`.
- **Formatting (manual)**: `<leader>lf` runs `/usr/bin/clang-format` via `conform.nvim`.
- **CMake LSP**: `neocmakelsp` provides completion and diagnostics inside `CMakeLists.txt`.

### Building & `compile_commands.json` (`cmake-tools.nvim`)
When you open a project containing `CMakeLists.txt`, `cmake-tools.nvim` loads automatically:
1. `<leader>mg` (`:CMakeGenerate`) configures CMake with `-DCMAKE_EXPORT_COMPILE_COMMANDS=1` and **automatically symlinks `compile_commands.json` to your project root** so `clangd` resolves project headers and `--clang-tidy` checks with zero manual steps.
2. `<leader>mb` (`:CMakeBuild`) builds the selected target (`<leader>mt` to pick build target, `<leader>mT` for Debug/Release).
3. `<leader>mr` (`:CMakeRun`) runs the launch target (`<leader>ml` to choose).
4. `<leader>md` (`:CMakeDebug`) builds and launches the target directly inside `nvim-dap` using GDB.

*(For non-CMake Make/Ninja projects, run `bear -- make` once to produce `compile_commands.json`.)*

### Debugging (Native GDB DAP)
- Uses your system **GDB** (`gdb --interpreter=dap`) — no extra debugger extension needed.
- Set breakpoints with `<leader>db` (or conditional `<leader>dB`), then start with `<leader>md` (CMake projects) or `<leader>dc` / `<F5>` (prompts for executable path or PID attach).
- `nvim-dap-view` opens automatically at the bottom with tabs for **scopes, watches, breakpoints, threads, exceptions, REPL, and console** (`<leader>du` toggles it, `<leader>dw` watches the word/selection under cursor).
- Step controls: `<F10>` / `<leader>do` (over), `<F11>` / `<leader>di` (into), `<F12>` / `<leader>dO` (out), `<leader>dC` (run to cursor), `<leader>dt` (terminate).

### C++ GoogleTest (`neotest-gtest`)
First-time setup per C++ project so `neotest-gtest` knows which compiled test binary to execute:
1. Build your test binary (e.g. `<leader>mb`).
2. Open a test `.cpp` file and open the summary tree (`<leader>ts`).
3. Mark tests/files with `m` in the summary tree, then run `:ConfigureGtest` and provide the path to the compiled test executable.
4. From then on, `<leader>tt` / `<leader>tf` / `<leader>td` run and debug GoogleTests inline.

---

## 5. Chezmoi Dotfiles Workflow

- **Find & edit any managed dotfile**: `<leader>fc` opens a Telescope picker over all `chezmoi`-managed files (`chezmoi.nvim`).
- **Editing inside `~/.local/share/chezmoi`**: Files opened from the chezmoi source tree are auto-watched and automatically run `chezmoi apply` on `:w`. Also available as a project in `<leader>pp`.
- **Editing live files (e.g. `~/.config/nvim/...`)**: Press `<leader>pc` to run `chezmoi re-add` on the current buffer directly from Neovim without leaving the editor.
- **Note on new/deleted files**: For brand-new files run `chezmoi add <path>`, and for deleted files run `chezmoi forget <path>` in the terminal, then commit/push from `~/.local/share/chezmoi`.
