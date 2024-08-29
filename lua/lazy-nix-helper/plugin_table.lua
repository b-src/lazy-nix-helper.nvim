local Util = require("lazy-nix-helper.util")

local M = {}

M.plugins = {}

function M.populate_provided_plugin_paths(input_plugin_table, friendly_plugin_names)
  for key, value in pairs(input_plugin_table) do
    local plugin_name = key
    if friendly_plugin_names then
      plugin_name = Util.normalize_plugin_name(plugin_name)
    end

    if Util.file_exists(value) then
      M.plugins[plugin_name] = value
    end
  end
end

function M.list_discovered_plugins()
  vim.print(M.plugins)
end

return M
