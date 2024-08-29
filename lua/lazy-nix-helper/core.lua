local Config = require("lazy-nix-helper.config")
local PluginDiscovery = require("lazy-nix-helper.plugin_discovery")
local PluginTable = require("lazy-nix-helper.plugin_table")
local Util = require("lazy-nix-helper.util")

local M = {}

local function get_friendly_plugin_path(plugin_name)
  local norm_plugin_name = Util.normalize_plugin_name(plugin_name)
  local nvim_appended = norm_plugin_name .. ".nvim"
  local nvim_removed = string.match(norm_plugin_name, "(.-)%.nvim$")
  local scm_appended = norm_plugin_name .. "-scm"
  -- would prefer to put all the candidate paths in an array and check that there aren't more than one
  -- non-nil values. since iterating over an array in lua will stop at the first nil value, there doesn't
  -- seem to be a great way to do this. try to refactor if another case is ever added
  local norm_plugin_path = PluginTable.plugins[norm_plugin_name]
  local nvim_appended_plugin_path = PluginTable.plugins[nvim_appended]
  local nvim_removed_plugin_path = nil
  if nvim_removed ~= nil then
    nvim_removed_plugin_path = PluginTable.plugins[nvim_removed]
  end
  local scm_appended_plugin_path = PluginTable.plugins[scm_appended]

  if not (norm_plugin_path or nvim_appended_plugin_path or nvim_removed_plugin_path or scm_appended_plugin_path) then
    return nil
  end

  if
    not (
      Util.xor(
        Util.xor(Util.xor(norm_plugin_path, nvim_appended_plugin_path), nvim_removed_plugin_path),
        scm_appended_plugin_path
      )
    )
  then
    Util.error("Name collision found when using friendly plugin discovery for " .. plugin_name)
  end

  -- at this point we know only one non-nil path was found
  if norm_plugin_path ~= nil then
    return norm_plugin_path
  end
  if nvim_appended_plugin_path ~= nil then
    return nvim_appended_plugin_path
  end
  if nvim_removed_plugin_path ~= nil then
    return nvim_removed_plugin_path
  end
  if scm_appended_plugin_path ~= nil then
    return scm_appended_plugin_path
  end
end

function M.get_plugin_path(plugin_name)
  if Config.options.auto_plugin_discovery and not PluginDiscovery.plugin_discovery_done then
    PluginDiscovery.populate_plugin_table()
  end

  if not plugin_name then
    Util.error("plugin_name not provided")
  end

  if Config.options.friendly_plugin_names then
    return get_friendly_plugin_path(plugin_name)
  end

  return PluginTable.plugins[plugin_name]
end

function M.lazypath()
  return M.get_plugin_path("lazy.nvim") or Config.options.lazypath
end

return M
