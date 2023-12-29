local Util = require("lazy-nix-helper.util")

local M = {}

M.namespace = vim.api.nvim_create_namespace("LazyNixHelper")

local defaults = {
  lazypath = nil,
  friendly_plugin_names = true,
  auto_plugin_discovery = false,
  input_plugin_table = {}
}

M.options = {}

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
  if M.options.lazypath == nil then
    Util.error("A default lazypath must be provided")
  end
end

return M
