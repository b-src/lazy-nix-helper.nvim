local Config = require("lazy-nix-helper.config")
local Core = require("lazy-nix-helper.core")
local Mason = require("lazy-nix-helper.mason")

local M = {}

-- public api
function M.setup(options)
  Config.setup(options)
end

function M.get_plugin_path(plugin_name)
  return Core.get_plugin_path(plugin_name)
end

function M.lazypath()
  return Core.lazypath()
end

function M.mason_enabled()
  return Mason.mason_enabled()
end

-- public debug/troubleshooting api
function M.list_discovered_plugins()
  Core.list_discovered_plugins()
end

return M
