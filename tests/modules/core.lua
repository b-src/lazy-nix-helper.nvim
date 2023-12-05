local Core = require("lazy-nix-helper.core")
local Config = require("lazy-nix-helper.config")

require("tests.init").setup_test_env()

local plenary = require("plenary")
local mock = require("luassert.mock")
local assert = require("luassert.assert")


-- TODO: fix test for lazy found in nix store
plenary.busted.describe("test lazypath", function()
  local lazy_nix_store_path = "nix/store/hash123-vimplugins-lazy.nvim"
  local default_lazypath = "default/lazypath"
  local tests = {
    { "lazy found in nix store", { ["lazy.nvim"] = lazy_nix_store_path }, lazy_nix_store_path },
    { "lazy not found in nix store", {}, default_lazypath},
  }

  for _, test in ipairs(tests) do
    plenary.busted.it(test[1], function()
      -- TODO: revert side effects?
      mock(Core, "M", { plugins = test[2] })
      -- mock(Core, "plugin_discovery_done", true)
      -- Core.plugin_discovery_done = true
      -- Core.plugins = test[2]

      local opts = { lazypath = default_lazypath }
      Config.setup(opts)

      assert.equals(test[3], Core.lazypath())

      mock.revert(Core)
    end)
  end
end)

plenary.busted.describe("test setup", function()
  plenary.busted.it("sets lazypath", function()
    local expected_result = "test/lazypath"
    Config.setup({ lazypath = expected_result })

    assert.equals(Config.options.lazypath, expected_result)
  end)
end)
