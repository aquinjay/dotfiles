-- lua/user/core/agent.lua
-- Helpers for pairing Neovim with Antigravity (`agy`).
--
-- Features:
--   1. Automatic buffer reload (`checktime`) when files change on disk.
--   2. Toggleable right-split `agy` / `agy --continue` terminal that persists
--      in the background + direct send of `@file:line` references.
--   3. One-keystroke context copy to system clipboard (`+`):
--      - <leader>cy  Copy `@relative/path:L<line>` (or line range in Visual mode)
--      - <leader>cf  Copy `@relative/path`
--      - <leader>cs  Copy fenced code snippet with `@relative/path:L<start>-L<end>` (Visual)
--      - <leader>cd  Copy current buffer's LSP diagnostics
--      - <leader>cD  Copy all workspace LSP diagnostics

local M = {}

--------------------------------------------------------------------------------
-- 1. Auto-reload files edited externally
--------------------------------------------------------------------------------
local autoread_group = vim.api.nvim_create_augroup("user_agent_autoread", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose", "TermLeave" }, {
  group = autoread_group,
  desc = "Check for external file changes and reload unmodified buffers",
  callback = function(ev)
    if vim.fn.getcmdwintype() ~= "" or vim.fn.mode() == "c" then
      return
    end
    if not vim.api.nvim_buf_is_valid(ev.buf) or vim.bo[ev.buf].buftype ~= "" then
      return
    end
    vim.cmd("silent! checktime")
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = autoread_group,
  desc = "Notify when a buffer is reloaded after external modification",
  callback = function(ev)
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ev.buf), ":.")
    vim.notify(("Reloaded %s (changed on disk)"):format(name ~= "" and name or "[No Name]"), vim.log.levels.INFO, {
      title = "Auto-reload",
    })
  end,
})

--------------------------------------------------------------------------------
-- 2. Toggleable `agy` right-split terminal
--------------------------------------------------------------------------------
local agy_term = {
  buf = nil,
  win = nil,
  job = nil,
}

local function agy_term_alive()
  return agy_term.buf
    and vim.api.nvim_buf_is_valid(agy_term.buf)
    and agy_term.job
    and vim.fn.jobwait({ agy_term.job }, 0)[1] == -1
end

local function open_agy_split(cmd)
  if vim.fn.executable("agy") ~= 1 then
    vim.notify("`agy` binary not found on PATH", vim.log.levels.ERROR, { title = "Antigravity" })
    return false
  end

  local width = math.max(55, math.floor(vim.o.columns * 0.42))
  vim.cmd(("botright %dvsplit"):format(width))
  local win = vim.api.nvim_get_current_win()

  if agy_term_alive() then
    vim.api.nvim_win_set_buf(win, agy_term.buf)
  else
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(win, buf)
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "agy_terminal"

    local job = vim.fn.jobstart(cmd, {
      term = true,
      on_exit = function()
        vim.schedule(function()
          if agy_term.win and vim.api.nvim_win_is_valid(agy_term.win) then
            vim.api.nvim_win_close(agy_term.win, true)
          end
          if agy_term.buf and vim.api.nvim_buf_is_valid(agy_term.buf) then
            pcall(vim.api.nvim_buf_delete, agy_term.buf, { force = true })
          end
          agy_term.win = nil
          agy_term.buf = nil
          agy_term.job = nil
        end)
      end,
    })

    vim.keymap.set("n", "q", function()
      M.toggle_agy(false)
    end, { buffer = buf, silent = true, desc = "Hide agy terminal" })

    agy_term.buf = buf
    agy_term.job = job
  end

  agy_term.win = win
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].winfixwidth = true
  vim.cmd("startinsert")
  return true
end

function M.toggle_agy(continue_last)
  -- If the agy split is already visible, hide it without killing the session.
  if agy_term.win and vim.api.nvim_win_is_valid(agy_term.win) then
    vim.cmd("stopinsert")
    vim.api.nvim_win_close(agy_term.win, true)
    agy_term.win = nil
    return
  end

  local cmd = continue_last and { "agy", "--continue" } or { "agy" }
  open_agy_split(cmd)
end

function M.send_to_agy(text)
  if not agy_term_alive() then
    if not open_agy_split({ "agy" }) then
      return
    end
  elseif not (agy_term.win and vim.api.nvim_win_is_valid(agy_term.win)) then
    open_agy_split({ "agy" })
  else
    vim.api.nvim_set_current_win(agy_term.win)
    vim.cmd("startinsert")
  end

  if agy_term.job then
    vim.api.nvim_chan_send(agy_term.job, text .. " ")
  end
end

--------------------------------------------------------------------------------
-- 3. Context copy & send helpers for agent prompts
--------------------------------------------------------------------------------
local severity_label = {
  [vim.diagnostic.severity.ERROR] = "ERROR",
  [vim.diagnostic.severity.WARN] = "WARN",
  [vim.diagnostic.severity.INFO] = "INFO",
  [vim.diagnostic.severity.HINT] = "HINT",
}

local function rel_path(bufnr)
  local full = vim.api.nvim_buf_get_name(bufnr or 0)
  if full == "" then
    return nil
  end
  return vim.fn.fnamemodify(full, ":.")
end

local function copy_to_clipboard(text, label)
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)
  vim.notify(("Copied %s"):format(label), vim.log.levels.INFO, { title = "Agent Context" })
end

local function visual_line_range()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  return start_line, end_line
end

local function exit_visual()
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "nx", false)
end

local function format_diagnostic(d)
  local line = (d.lnum or 0) + 1
  local col = (d.col or 0) + 1
  local sev = severity_label[d.severity] or "INFO"
  local src = d.source and (" (" .. d.source .. ")") or ""
  local msg = (d.message or ""):gsub("\n", " ")
  return ("- L%d:%d [%s]%s: %s"):format(line, col, sev, src, msg)
end

function M.copy_file_ref()
  local path = rel_path(0)
  if not path then
    vim.notify("Current buffer has no file path", vim.log.levels.WARN, { title = "Agent Context" })
    return
  end
  local ref = "@" .. path
  copy_to_clipboard(ref, ref)
end

function M.copy_location_normal()
  local path = rel_path(0)
  if not path then
    vim.notify("Current buffer has no file path", vim.log.levels.WARN, { title = "Agent Context" })
    return
  end
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local ref = ("@%s:L%d"):format(path, line)
  copy_to_clipboard(ref, ref)
end

function M.copy_location_visual()
  local path = rel_path(0)
  if not path then
    vim.notify("Current buffer has no file path", vim.log.levels.WARN, { title = "Agent Context" })
    return
  end
  local s, e = visual_line_range()
  exit_visual()
  local ref = s == e and ("@%s:L%d"):format(path, s) or ("@%s:L%d-L%d"):format(path, s, e)
  copy_to_clipboard(ref, ref)
end

function M.send_location_normal()
  local path = rel_path(0)
  if not path then
    vim.notify("Current buffer has no file path", vim.log.levels.WARN, { title = "Agent Context" })
    return
  end
  local line = vim.api.nvim_win_get_cursor(0)[1]
  M.send_to_agy(("@%s:L%d"):format(path, line))
end

function M.send_location_visual()
  local path = rel_path(0)
  if not path then
    vim.notify("Current buffer has no file path", vim.log.levels.WARN, { title = "Agent Context" })
    return
  end
  local s, e = visual_line_range()
  exit_visual()
  local ref = s == e and ("@%s:L%d"):format(path, s) or ("@%s:L%d-L%d"):format(path, s, e)
  M.send_to_agy(ref)
end

function M.copy_snippet_visual()
  local path = rel_path(0)
  if not path then
    vim.notify("Current buffer has no file path", vim.log.levels.WARN, { title = "Agent Context" })
    return
  end
  local s, e = visual_line_range()
  exit_visual()
  local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)
  local ft = vim.bo.filetype or ""
  local header = s == e and ("@%s:L%d"):format(path, s) or ("@%s:L%d-L%d"):format(path, s, e)
  local snippet = table.concat({
    header,
    "```" .. ft,
    table.concat(lines, "\n"),
    "```",
  }, "\n")
  copy_to_clipboard(snippet, ("snippet %s"):format(header))
end

function M.copy_buffer_diagnostics()
  local path = rel_path(0) or "[No Name]"
  local diags = vim.diagnostic.get(0)
  if #diags == 0 then
    vim.notify("No diagnostics in current buffer", vim.log.levels.INFO, { title = "Agent Context" })
    return
  end
  table.sort(diags, function(a, b)
    if a.lnum ~= b.lnum then
      return a.lnum < b.lnum
    end
    return (a.col or 0) < (b.col or 0)
  end)
  local out = { ("Diagnostics for @%s:"):format(path) }
  for _, d in ipairs(diags) do
    table.insert(out, format_diagnostic(d))
  end
  copy_to_clipboard(table.concat(out, "\n"), ("%d buffer diagnostic(s)"):format(#diags))
end

function M.copy_workspace_diagnostics()
  local diags = vim.diagnostic.get(nil)
  if #diags == 0 then
    vim.notify("No diagnostics in loaded buffers", vim.log.levels.INFO, { title = "Agent Context" })
    return
  end
  local by_file = {}
  local files = {}
  for _, d in ipairs(diags) do
    local path = rel_path(d.bufnr) or ("[buf " .. tostring(d.bufnr) .. "]")
    if not by_file[path] then
      by_file[path] = {}
      table.insert(files, path)
    end
    table.insert(by_file[path], d)
  end
  table.sort(files)

  local out = {}
  for _, path in ipairs(files) do
    local list = by_file[path]
    table.sort(list, function(a, b)
      if a.lnum ~= b.lnum then
        return a.lnum < b.lnum
      end
      return (a.col or 0) < (b.col or 0)
    end)
    table.insert(out, ("@%s:"):format(path))
    for _, d in ipairs(list) do
      table.insert(out, format_diagnostic(d))
    end
  end
  copy_to_clipboard(table.concat(out, "\n"), ("%d workspace diagnostic(s)"):format(#diags))
end

--------------------------------------------------------------------------------
-- Keymaps
--------------------------------------------------------------------------------
local map = vim.keymap.set
map({ "n", "t" }, "<M-a>", function()
  M.toggle_agy(false)
end, { desc = "Toggle agy terminal (Normal/Terminal)" })
map("n", "<leader>ca", function()
  M.toggle_agy(false)
end, { desc = "Toggle agy terminal" })
map("n", "<leader>cC", function()
  M.toggle_agy(true)
end, { desc = "Toggle agy --continue" })
map("n", "<leader>cp", M.send_location_normal, { desc = "Send @file:line to agy" })
map("x", "<leader>cp", M.send_location_visual, { desc = "Send @file:lines to agy" })

map("n", "<leader>cy", M.copy_location_normal, { desc = "Copy @file:line" })
map("x", "<leader>cy", M.copy_location_visual, { desc = "Copy @file:Lstart-Lend" })
map("x", "<leader>cs", M.copy_snippet_visual, { desc = "Copy fenced snippet + @file:lines" })
map("n", "<leader>cf", M.copy_file_ref, { desc = "Copy @file path" })
map("n", "<leader>cd", M.copy_buffer_diagnostics, { desc = "Copy buffer diagnostics" })
map("n", "<leader>cD", M.copy_workspace_diagnostics, { desc = "Copy workspace diagnostics" })

return M
