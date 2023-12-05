local Core = require("lazy-nix-helper.core")

M = {}

local setup_complete = false

function M.setup_test_env()
  if not setup_complete then
    local plenary_path = Core.get_plugin_path("plenary.nvim")
    -- if no plenary path found, assume we are on a non-nixos system and plenary is already available
    if plenary_path ~= nil then
      vim.opt.rtp:prepend(plenary_path)
    end

    setup_complete = true
  end
end

return M


