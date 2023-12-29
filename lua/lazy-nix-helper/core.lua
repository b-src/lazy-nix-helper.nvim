local Config = require("lazy-nix-helper.config")
local PluginTable = require("lazy-nix-helper.plugin_table")
local Util = require("lazy-nix-helper.util")

local M = {}
M.vimplugin_capture_group = ".vimplugin%-(.*)"
M.lua5_1_capture_group = ".lua5%.1%-(.*)"

-- would prefer these to be local variables but this makes testing easier
M.plugin_discovery_done = false

local function normalize_plugin_name(plugin_name)
  local plugin_name_lower = string.lower(plugin_name)
  local plugin_name_separators = string.gsub(plugin_name_lower, "_", "-")
  return plugin_name_separators
end

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
    plugin_name = normalize_plugin_name(plugin_name)
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

local function populate_plugin_table()
  -- TODO: is extending the table better than just setting it? does it matter?
  -- vim.tbl.extend("force", M.plugins, M.build_plugin_table())
  PluginTable.plugins = M.build_plugin_table()
end

local function get_friendly_plugin_path(plugin_name)
  local norm_plugin_name = normalize_plugin_name(plugin_name)
  local nvim_appended = norm_plugin_name .. ".nvim"
  local nvim_removed = string.match(norm_plugin_name, "(.-)%.nvim$")
  -- would prefer to put all the candidate paths in an array and check that there aren't more than one
  -- non-nil values. since iterating over an array in lua will stop at the first nil value, there doesn't
  -- seem to be a great way to do this. try to refactor if another case is ever added
  local norm_plugin_path = PluginTable.plugins[norm_plugin_name]
  local nvim_appended_plugin_path = PluginTable.plugins[nvim_appended]
  local nvim_removed_plugin_path = nil
  if nvim_removed ~= nil then
    nvim_removed_plugin_path = PluginTable.plugins[nvim_removed]
  end

  if not (norm_plugin_path or nvim_appended_plugin_path or nvim_removed_plugin_path) then
    return nil
  end

  if not (Util.xor(Util.xor(norm_plugin_path, nvim_appended_plugin_path), nvim_removed_plugin_path)) then
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
end

function M.get_plugin_path(plugin_name)
  if not M.plugin_discovery_done then
    populate_plugin_table()
    M.plugin_discovery_done = true
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

function M.list_discovered_plugins()
  vim.print(PluginTable.plugins)
end

return M
