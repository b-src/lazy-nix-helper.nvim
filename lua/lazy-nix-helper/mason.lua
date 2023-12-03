local Util = require("lazy-nix-helper.util")

local M = {}

function M.mason_enabled()
  if Util.in_a_nix_environment() then
    return false
  end

  return true
end

return M
