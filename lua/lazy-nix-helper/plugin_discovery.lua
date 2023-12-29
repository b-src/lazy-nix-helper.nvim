local Config = require("lazy-nix-helper.config")
local PluginTable = require("lazy-nix-helper.plugin_table")
local Util = require("lazy-nix-helper.util")


-- This module contains the original plugin discovery mechanism for Lazy-Nix-Helper
-- Searching the nix store like this is a nix anti-pattern.
-- This method works in only a subset of nix/nixos use cases and config arrangements.
-- Lazy-Nix-Helper now supports passing in a list of plugin paths that was generated from within a nix config,
-- which is the proper way to do this.
--
-- This functionality is left in place for people who started using Lazy-Nix-Helper
-- before an externally generated plugin list was supported, but it should not be used for new configurations.
local M = {}

M.vimplugin_capture_group = ".vimplugin%-(.*)"
M.lua5_1_capture_group = ".lua5%.1%-(.*)"

M.plugin_discovery_done = false

function M.parse_plugin_name_from_nix_store_path(path, capture_group)
  -- path looks like:
  -- /nix/store/<hash>-vimplugin-<name>[-<date>]
  -- use string.match to capture everything after "vimplugin-"
  local plugin_name_with_possible_date = string.match(path, capture_group)
  -- date is formatted -YYYY-DD-YY. capture on digits fitting that format at the end of the string
  local plugin_name = string.match(plugin_name_with_possible_date, "(.-)%-%d%d%d%d%-%d%d%-%d%d$")
  if plugin_name == nil then
    plugin_name = plugin_name_with_possible_date
  end
  if Config.options.friendly_plugin_names then
    plugin_name = Util.normalize_plugin_name(plugin_name)
  end
  return plugin_name
end

local function search_nix_store_for_paths_containing_string(query_string)
  -- NOTE: this will only work for nixos, not packages installed via nix on non-nixos systems
  local nix_command = "nix-store --query --requisites /run/current-system | grep " .. query_string .. " | sort"
  local nix_search_handle = io.popen(nix_command)
  if nix_search_handle == nil then
    Util.error("Unable to get nix-store search results")
  else
    -- this is needed because using file:lines() will return an interator, which means if we close the file
    -- handle we can't use the results
    local nix_search_results_text = nix_search_handle:read("*a")
    -- TODO: this results in an empty string at the end of the table, which will break processing later
    -- figure out if this happens every time.
    -- prefer to just remove it here
    local nix_search_results = vim.split(nix_search_results_text, "\n")
    nix_search_handle:close()
    return nix_search_results
  end
end

local function populate_plugin_table_base(grep_string, capture_group)
  local plugin_table = {}

  local nix_search_results = search_nix_store_for_paths_containing_string(grep_string)
  for _, line in ipairs(nix_search_results) do
    if line ~= "" then
      local plugin_path = line
      local plugin_name = M.parse_plugin_name_from_nix_store_path(line, capture_group)

      if Util.table_contains(plugin_table, plugin_name) then
        Util.error("Plugin name collision detected for plugin name " .. plugin_name)
      end

      plugin_table[plugin_name] = plugin_path
    end
  end

  return plugin_table
end

local function populate_plugin_table_vimplugins()
  return populate_plugin_table_base("vimplugin", M.vimplugin_capture_group)
end

local function populate_plugin_table_lua5_1()
  return populate_plugin_table_base("lua5.1", M.lua5_1_capture_group)
end

function M.build_plugin_table()
  local plugin_table = {}

  if Util.in_a_nix_environment() and Util.nix_store_installed() then
    local vimplugins_table = populate_plugin_table_vimplugins()
    local lua5_1_table = populate_plugin_table_lua5_1()

    plugin_table = vim.tbl_extend("error", plugin_table, vimplugins_table)
    plugin_table = vim.tbl_extend("error", plugin_table, lua5_1_table)
  end

  return plugin_table
end

function M.populate_plugin_table()
  PluginTable.plugins = M.build_plugin_table()
  M.plugin_discovery_done = true
end

return M
