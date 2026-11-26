-- Obsidian vault locations, shared by plugins/obsidian.lua and after/ftplugin/markdown.lua.
local M = {
  { name = "thinking", path = "~/Documents/Thinking Vault" },
  { name = "consulting", path = "~/Documents/consulting_practice/Consulting Vault" },
}

-- Returns true if `file` (absolute path) lives inside one of the vaults.
function M.contains(file)
  for _, vault in ipairs(M) do
    if vim.startswith(file, vim.fs.normalize(vault.path) .. "/") then
      return true
    end
  end
  return false
end

return M
