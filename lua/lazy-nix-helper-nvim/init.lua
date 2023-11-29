local M = {}

local plugins = {}

--
-- TODO: should this be checking nix-store is installed instead?
function M.nix_is_installed()
  return vim.fn.executable("nix")
end

function M.parse_plugin_name_from_nix_store_path(path)
  -- path looks like:
  -- /nix/store/<hash>-vimplugin-<name>[-<date>]
  -- use string.match to capture everything after "vimplugin-"
  local plugin_name_with_possible_date = string.match(path, ".vimplugin%-(.*)")
  -- date is formatted -YYYY-DD-YY. capture on digits fitting that format at the end of the string
  local plugin_name = string.match(plugin_name_with_possible_date, "(.-)%-%d%d%d%d%-%d%d%-%d%d$")
  if plugin_name == nil then
    plugin_name == plugin_name_with_possible_date
  end
  return plugin_name
end

function M.populate_plugin_table()
  if M.nix_is_installed then
    -- NOTE: this will only work for nixos, not packages installed via nix on non-nixos systems
    local nix_command = "nix-store --query --requisites /run/current-system | grep vimplugin | sort"
    local nix_search_handle = io.popen(nix_command)
    local nix_search_results = nix_search_handle:lines()
    nix_search_handle:close()
    for line in nix_search_results do
      print(line)
      local plugin_path = line
      local plugin_name = M.parse_plugin_name_from_nix_store_path(path)
      plugins[plugin_name] = plugin_path
    end
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
