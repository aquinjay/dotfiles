-- helper module to add plugins and their options aka specifications
local M = {}

M.plugin_spec = {}

-- Function to add plugins and specs to the plugin table
function M.spec(item)
  table.insert(M.plugin_spec, { import = item })
end

return M
