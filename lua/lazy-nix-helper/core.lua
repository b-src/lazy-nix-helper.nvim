local Config = require("lazy-nix-helper.config")
local Util = require("lazy-nix-helper.util")

local M = {}
M.vimplugin_capture_group = ".vimplugin%-(.*)"
M.lua5_1_capture_group = ".lua5%.1%-(.*)"

-- would prefer these to be local variables but this makes testing easier
M.plugin_discovery_done = false
M.plugins = {}

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
  return plugin_name
end

local function search_nix_store_for_paths_containing_string(query_string)
  -- NOTE: this will only work for nixos, not packages installed via nix on non-nixos systems
  local nix_command = "nix-store --query --requisites /run/current-system | grep " .. query_string .. " | sort"
  local nix_search_handle = io.popen(nix_command)
  if nix_search_handle == nil then
    Util.error("Unable to get nix-store search results")
  else
    local nix_search_results = nix_search_handle:lines()
    -- TODO: this is needed, we don't want to leave dangling file handles for lua's GC to clean up
    -- however, when this is included, attempting to use nix_search_results below gives an error:
    -- "attempt to use a closed file"
    -- I'm not sure why that is.
    -- nix_search_handle:close()
  return nix_search_results
  end
end

local function populate_plugin_table_base(grep_string, capture_group)
  local plugin_table = {}

  local nix_search_results = search_nix_store_for_paths_containing_string(grep_string)
  for line in nix_search_results do
    local plugin_path = line
    local plugin_name = M.parse_plugin_name_from_nix_store_path(line, capture_group)

    if Util.table_contains(plugin_table, plugin_name) then
      Util.error("Plugin name collision detected for plugin name " .. plugin_name)
    end

    plugin_table[plugin_name] = plugin_path
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

local function populate_plugin_table()
  -- TODO: is extending the table better than just setting it? does it matter?
  -- vim.tbl.extend("force", M.plugins, M.build_plugin_table())
  M.plugins = M.build_plugin_table()
end

function M.get_plugin_path(plugin_name)
  if not M.plugin_discovery_done then
    populate_plugin_table()
    M.plugin_discovery_done = true
  end

  if not plugin_name then
    Util.error("plugin_name not provided")
  end
  -- TODO: is this check necessary?
  if not Util.table_contains(M.plugins, plugin_name) then
    return nil
  end
  return M.plugins[plugin_name]
end

function M.lazypath()
  return M.get_plugin_path("lazy.nvim") or Config.options.lazypath
end

function M.list_discovered_plugins()
  vim.print(M.plugins)
end

return M
