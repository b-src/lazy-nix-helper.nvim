local Config = require("lazy-nix-helper.config")
local Util = require("lazy-nix-helper.util")

local plenary = require("plenary")
local mock = require("luassert.mock")
local assert = require("luassert.assert")


plenary.busted.describe("test setup", function()
  plenary.busted.it("throws an error if no lazypath provided", function()
      local Util = mock(Util, true)

      Config.setup({})

      assert.stub(Util.error).was_called_with("A default lazypath must be provided")

      mock.revert(Util)
  end)
end)

plenary.busted.describe("test setup", function()
  plenary.busted.it("sets lazypath", function()
    local expected_result = "test/lazypath"
    Config.setup({ lazypath = expected_result })

    assert.equals(Config.options.lazypath, expected_result)
  end)
end)
