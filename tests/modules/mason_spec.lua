local Mason = require("lazy-nix-helper.mason")
local Util = require("lazy-nix-helper.util")

local plenary = require("plenary")
local mock = require("luassert.mock")
local assert = require("luassert.assert")

plenary.busted.describe("test mason_enabled", function()
  local tests = {
    { true, false },
    { false, true },
  }

  for _, test in ipairs(tests) do
    plenary.busted.it("returns correct value when in_a_nix_environment returns " .. tostring(test[1]), function()
      local Util = mock(Util, true)
      Util.in_a_nix_environment.returns(test[1])

      local result = Mason.mason_enabled()

      assert.equals(result, test[2])

      mock.revert(Util)
    end)
  end
end)
