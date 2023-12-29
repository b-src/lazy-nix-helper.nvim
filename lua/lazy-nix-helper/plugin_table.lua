local Util = require("lazy-nix-helper.util")

local M = {}

M.plugins = {}

function M.populate_provided_plugin_paths(input_plugin_table)
  for key, value in ipairs(input_plugin_table) do
    if Util.file_exists(value) then
      M.plugins[key] = value
    end
  end
end

return M
