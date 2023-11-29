local M = {}

local plugins = {}

-- TODO: list nix installed plugins
-- TODO: map plugin names to nix store paths

-- function M.error(msg)
--   vim.notify(msg, vim.log.levels.ERROR, { title = "lazy-nix-helper" })
-- end
--
-- TODO: should this be checking nix-store is installed instead?
function M.nix_is_installed()
  return vim.fn.executable("nix")
end


function M.populate_plugin_table()
  if M.nix_is_installed then
    -- NOTE: this will only work for nixos, not packages installed via nix on non-nixos systems
    local nix_command = "nix-store --query --requisites /run/current-system | grep vimplugin | cut -d- -f3- | sort"
    local nix_search_handle = io.popen(nix_command)
    local nix_search_results = nix_search_handle:lines()
    nix_search_handle:close()
    -- TODO: parse nix command output into plugin names and nix store paths
    for line in nix_search_results do
      local plugin_name = nil
      local plugin_path = nil
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
