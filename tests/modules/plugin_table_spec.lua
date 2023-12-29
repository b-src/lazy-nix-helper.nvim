local Config = require("lazy-nix-helper.config")
local PluginTable = require("lazy-nix-helper.plugin_table")
local Util = require("lazy-nix-helper.util")

local plenary = require("plenary")
local assert = require("luassert.assert")
local mock = require("luassert.mock")

plenary.busted.describe("test populate_provided_plugin_paths", function()
  local plugin_name = "treesitter"
  local plugin_path = "/nix/store/2s6wcjbxgwpjisdjw19r7vvx05sj042m-vimplugin-nvim-treesitter"
  local test_plugin_input_table = {}
  test_plugin_input_table[plugin_name] = plugin_path

  local tests = {
    {
      "adds plugin to table when the file path exists",
      test_plugin_input_table,
      true,
      plugin_path,
    },
    {
      "doesn't add plugin to table when file path does not exist",
      test_plugin_input_table,
      false,
      nil,
    },
  }

  for _, test in ipairs(tests) do
    plenary.busted.it(test[1], function()
      PluginTable.plugins = {}
      local mock_util = mock(Util, true)
      mock_util.file_exists.returns(test[3])

      local opts = { lazypath = "", input_plugin_table = test[2] }
      Config.setup(opts)

      assert.equals(test[4], PluginTable.plugins[plugin_name])

      mock.revert(mock_util)
    end)
  end
end)
