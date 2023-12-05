local Core = require("lazy-nix-helper.core")
local Config = require("lazy-nix-helper.config")

-- require("tests.init").setup_test_env()
local plenary_path = Core.get_plugin_path("plenary.nvim")
-- if no plenary path found, assume we are on a non-nixos system and plenary is already available
if plenary_path ~= nil then
  vim.opt.rtp:prepend(plenary_path)
end

local plenary = require("plenary")
local assert = require("luassert.assert")


plenary.busted.describe("test parse_plugin_name_from_nix_store_path", function()
  -- TODO: make these shared constants
  local vimplugin_test_path = "/nix/store/2s6wcjbxgwpjisdjw19r7vvx05sj042m-vimplugin-nvim-treesitter"
  local vimplugin_test_path_with_date = "/nix/store/2s6wcjbxgwpjisdjw19r7vvx05sj042m-vimplugin-nvim-treesitter-2023-10-23"
  local lua_test_path = "/nix/store/zhigkkdw9az0gxy8ylbnhzwgkm6cdcw2-lua5.1-telescope.nvim-2023-10-23"
  local lua_test_path_with_date = "/nix/store/zhigkkdw9az0gxy8ylbnhzwgkm6cdcw2-lua5.1-telescope.nvim-2023-10-23"

  local tests = {
    { "parses plugin name from vimplugins package set", vimplugin_test_path, Core.vimplugin_capture_group, "nvim-treesitter" },
    { "parses plugin name from vimplugins package set with date suffix", vimplugin_test_path_with_date, Core.vimplugin_capture_group, "nvim-treesitter" },
    { "parses plugin name from lua5.1 package set", lua_test_path, Core.lua5_1_capture_group, "telescope.nvim" },
    { "parses plugin name from lua5.1 package set with date suffix", lua_test_path_with_date, Core.lua5_1_capture_group, "telescope.nvim" },
  }

  for _, test in ipairs(tests) do
    plenary.busted.it(test[1], function()
      assert.equals(test[4], Core.parse_plugin_name_from_nix_store_path(test[2], test[3]))
    end)
  end
end)

plenary.busted.describe("test get_plugin_path", function()
  local expected_found_plugin_path = "/nix/store/hash123-packageset-plugin-name"
  local wrong_path = "/nix/store/hash456-packageset-other-plugin"
  local tests = {
    { "returns path when plugin found", { ["myplugin"] = expected_found_plugin_path }, "myplugin", expected_found_plugin_path },
    { "returns nil when plugin not found", { ["otherplugin"] = wrong_path }, "myplugin", nil },
    { "is case sensitive plugin found", { ["MyPlugin"] = expected_found_plugin_path }, "MyPlugin", expected_found_plugin_path },
    { "is case sensitive plugin not found", { ["MyPlugin"] = expected_found_plugin_path }, "myplugin", nil },
    { "is hyphen/underscore sensitive hyphen found", { ["my-plugin"] = expected_found_plugin_path }, "my-plugin", expected_found_plugin_path },
    { "is hyphen/underscore sensitive hyphen not found", { ["my-plugin"] = expected_found_plugin_path }, "my_plugin", nil },
    { "is hyphen/underscore sensitive underscore found", { ["my_plugin"] = expected_found_plugin_path }, "my_plugin", expected_found_plugin_path },
    { "is hyphen/underscore sensitive underscore not found", { ["my_plugin"] = expected_found_plugin_path }, "my-plugin", nil },
    { "does not find plugin path when .nvim suffix missing", { ["myplugin.nvim"] = expected_found_plugin_path }, "myplugin", nil },
    { "does not find plugin path when unneeded .nvim suffix present", { ["myplugin"] = expected_found_plugin_path }, "myplugin.nvim", nil },
  }

  for _, test in ipairs(tests) do
    plenary.busted.it(test[1], function()
      -- would prefer to mock Core.build_plugin_table to return the expected test plugin table,
      -- but can't get that to work at the moment
      local orig_plugins = Core.plugins
      Core.plugins = test[2]
      assert(Core.plugin_discovery_done)

      assert.equals(test[4], Core.get_plugin_path(test[3]))

      Core.plugins = orig_plugins
    end)
  end

end)

plenary.busted.describe("test lazypath", function()
  local lazy_nix_store_path = "nix/store/hash123-vimplugins-lazy.nvim"
  local default_lazypath = "default/lazypath"
  local tests = {
    { "lazy found in nix store", { ["lazy.nvim"] = lazy_nix_store_path }, lazy_nix_store_path },
    { "lazy not found in nix store", {}, default_lazypath},
  }

  for _, test in ipairs(tests) do
    plenary.busted.it(test[1], function()
      -- would prefer to mock Core.build_plugin_table to return the expected test plugin table,
      -- but can't get that to work at the moment
      local orig_plugins = Core.plugins
      Core.plugins = test[2]
      assert(Core.plugin_discovery_done)

      local opts = { lazypath = default_lazypath }
      Config.setup(opts)

      assert.equals(test[3], Core.lazypath())

      Core.plugins = orig_plugins
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
