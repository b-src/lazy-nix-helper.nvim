local Util = require("lazy-nix-helper.util")
local Config = require("lazy-nix-helper.config")

local M = {}

local plugins = {}

function M.setup(options)
  require("lazy-nix-helper.config").setup(options)
end

-- TODO: should this be checking nix-store is installed instead?
local function nix_is_installed()
  return vim.fn.executable("nix")
end

local function parse_plugin_name_from_nix_store_path(path)
  -- path looks like:
  -- /nix/store/<hash>-vimplugin-<name>[-<date>]
  -- use string.match to capture everything after "vimplugin-"
  local plugin_name_with_possible_date = string.match(path, ".vimplugin%-(.*)")
  -- date is formatted -YYYY-DD-YY. capture on digits fitting that format at the end of the string
  local plugin_name = string.match(plugin_name_with_possible_date, "(.-)%-%d%d%d%d%-%d%d%-%d%d$")
  if plugin_name == nil then
    plugin_name = plugin_name_with_possible_date
  end
  return plugin_name
end

function M.populate_plugin_table()
  if nix_is_installed then
    -- NOTE: this will only work for nixos, not packages installed via nix on non-nixos systems
    local nix_command = "nix-store --query --requisites /run/current-system | grep vimplugin | sort"
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
      for line in nix_search_results do
        local plugin_path = line
        local plugin_name = parse_plugin_name_from_nix_store_path(line)
        plugins[plugin_name] = plugin_path
      end
    end
  end
end

local function table_contains(table, key)
  return table[key] ~= nil
end

function M.get_plugin_path(plugin_name)
  if not plugin_name then
    Util.error("plugin_name not provided")
  end
  if not table_contains(plugins, plugin_name) then
    return nil
  end
  return plugins[plugin_name]
end

function M.lazypath()
  return M.get_plugin_path("lazy") or Config.options.lazypath
end


return M
