local PluginDiscovery = require("lazy-nix-helper.plugin_discovery")

local plenary = require("plenary")
local assert = require("luassert.assert")

plenary.busted.describe("test parse_plugin_name_from_nix_store_path", function()
  -- TODO: make these shared constants
  local vimplugin_test_path = "/nix/store/2s6wcjbxgwpjisdjw19r7vvx05sj042m-vimplugin-nvim-treesitter"
  local vimplugin_test_path_with_date =
    "/nix/store/2s6wcjbxgwpjisdjw19r7vvx05sj042m-vimplugin-nvim-treesitter-2023-10-23"
  local lua_test_path = "/nix/store/zhigkkdw9az0gxy8ylbnhzwgkm6cdcw2-lua5.1-telescope.nvim-2023-10-23"
  local lua_test_path_with_date = "/nix/store/zhigkkdw9az0gxy8ylbnhzwgkm6cdcw2-lua5.1-telescope.nvim-2023-10-23"

  local tests = {
    {
      "parses plugin name from vimplugins package set",
      vimplugin_test_path,
      PluginDiscovery.vimplugin_capture_group,
      "nvim-treesitter",
    },
    {
      "parses plugin name from vimplugins package set with date suffix",
      vimplugin_test_path_with_date,
      PluginDiscovery.vimplugin_capture_group,
      "nvim-treesitter",
    },
    { "parses plugin name from lua5.1 package set", lua_test_path, PluginDiscovery.lua5_1_capture_group, "telescope.nvim" },
    {
      "parses plugin name from lua5.1 package set with date suffix",
      lua_test_path_with_date,
      PluginDiscovery.lua5_1_capture_group,
      "telescope.nvim",
    },
  }

  for _, test in ipairs(tests) do
    plenary.busted.it(test[1], function()
      assert.equals(test[4], PluginDiscovery.parse_plugin_name_from_nix_store_path(test[2], test[3]))
    end)
  end
end)
