-- helper table & function to add plugins and their options aka specifications

LAZY_PLUGIN_SPEC = {}

-- Function to add plugins and specs to the plugin table
function spec(item)
  table.insert(LAZY_PLUGIN_SPEC, { import = item })
end
