local M = {}

local plugins = {}

-- TODO: list nix installed plugins
-- TODO: map plugin names to nix store paths



function M.populate_plugin_table()
  -- TODO: create nix command to query either the nix store or nix configuration file for packages prefixed with 'neovim.plugins'
  local nix_command = ""
  -- TODO: use io.popen to run the nix command and read the result into a local variable
  local nix_output = nil
  -- TODO: parse nix command output into plugin names and nix store paths
  for line in nix_output do
    local plugin_name = nil
    local plugin_path = nil
    plugins[plugin_name] = plugin_path
  end
end


function M.tableContains(table, key)
  return table[key] ~= nil
end

function M.get_plugin_path(plugin_name)
  if not plugin_name then
    error("plugin_name not provided")
  end
  if not M.tableContains(plugins, plugin_name) then
    local message = 
    error("lazy-nix-helper plugin table does not contain " .. plugin_name)
  end
  return plugins[plugin_name]
end


return M
