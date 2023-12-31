local Config = require("lazy-nix-helper.config")
local Core = require("lazy-nix-helper.core")
local Mason = require("lazy-nix-helper.mason")
local PluginTable = require("lazy-nix-helper.plugin_table")
local Util = require("lazy-nix-helper.util")

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
  PluginTable.list_discovered_plugins()
end

function M.list_input_plugins()
  Config.list_input_plugins()
end

function M.print_environment_info()
  Util.print_environment_info()
end

return M
