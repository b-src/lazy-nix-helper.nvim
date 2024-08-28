local Core = require("lazy-nix-helper.core")
local Config = require("lazy-nix-helper.config")
local PluginTable = require("lazy-nix-helper.plugin_table")

local plenary = require("plenary")
local assert = require("luassert.assert")

plenary.busted.describe("test get_plugin_path", function()
  local expected_found_plugin_path = "/nix/store/hash123-packageset-plugin-name"
  local wrong_path = "/nix/store/hash456-packageset-other-plugin"
  local tests = {
    {
      "cmp_luasnip is handled correctly friendly names",
      { friendly_plugin_names = true },
      { ["cmp_luasnip"] = expected_found_plugin_path },
      "cmp_luasnip",
      expected_found_plugin_path,
    },
    {
      "FixCursorHold.nvim is handled correctly friendly names",
      { friendly_plugin_names = true },
      { ["FixCursorHold.nvim"] = expected_found_plugin_path },
      "FixCursorHold.nvim",
      expected_found_plugin_path,
    },
    {
      "returns path when plugin found strict names",
      { friendly_plugin_names = false },
      { ["myplugin"] = expected_found_plugin_path },
      "myplugin",
      expected_found_plugin_path,
    },
    {
      "returns path when plugin found friendly names",
      { friendly_plugin_names = true },
      { ["myplugin"] = expected_found_plugin_path },
      "myplugin",
      expected_found_plugin_path,
    },
    {
      "returns nil when plugin not found",
      { friendly_plugin_names = false },
      { ["otherplugin"] = wrong_path },
      "myplugin",
      nil,
    },
    {
      "is case sensitive strict names plugin found",
      { friendly_plugin_names = false },
      { ["MyPlugin"] = expected_found_plugin_path },
      "MyPlugin",
      expected_found_plugin_path,
    },
    {
      "is case sensitive strict names plugin not found",
      { friendly_plugin_names = false },
      { ["MyPlugin"] = expected_found_plugin_path },
      "myplugin",
      nil,
    },
    {
      "is not case sensitive friendly names plugin found",
      { friendly_plugin_names = true },
      { ["myplugin"] = expected_found_plugin_path },
      "MyPlugin",
      expected_found_plugin_path,
    },
    {
      "is hyphen/underscore sensitive strict names hyphen found",
      { friendly_plugin_names = false },
      { ["my-plugin"] = expected_found_plugin_path },
      "my-plugin",
      expected_found_plugin_path,
    },
    {
      "is not hyphen/underscore sensitive friendly names hyphen found",
      { friendly_plugin_names = true },
      { ["my-plugin"] = expected_found_plugin_path },
      "my_plugin",
      expected_found_plugin_path,
    },
    {
      "is hyphen/underscore sensitive strict names hyphen not found",
      { friendly_plugin_names = false },
      { ["my-plugin"] = expected_found_plugin_path },
      "my_plugin",
      nil,
    },
    {
      "is hyphen/underscore sensitive strict names underscore found",
      { friendly_plugin_names = false },
      { ["my_plugin"] = expected_found_plugin_path },
      "my_plugin",
      expected_found_plugin_path,
    },
    {
      "is hyphen/underscore sensitive strict names underscore not found",
      { friendly_plugin_names = false },
      { ["my_plugin"] = expected_found_plugin_path },
      "my-plugin",
      nil,
    },
    {
      "strict names does not find plugin path when .nvim suffix missing",
      { friendly_plugin_names = false },
      { ["myplugin.nvim"] = expected_found_plugin_path },
      "myplugin",
      nil,
    },
    {
      "friendly names finds plugin path when .nvim suffix missing",
      { friendly_plugin_names = true },
      { ["myplugin.nvim"] = expected_found_plugin_path },
      "myplugin",
      expected_found_plugin_path,
    },
    {
      "strict names does not find plugin path when unneeded .nvim suffix present",
      { friendly_plugin_names = false },
      { ["myplugin"] = expected_found_plugin_path },
      "myplugin.nvim",
      nil,
    },
    {
      "friendly names finds plugin path when unneeded .nvim suffix present",
      { friendly_plugin_names = true },
      { ["myplugin"] = expected_found_plugin_path },
      "myplugin.nvim",
      expected_found_plugin_path,
    },
  }

  for _, test in ipairs(tests) do
    plenary.busted.it(test[1], function()
      local opts = { lazypath = "" }
      opts = vim.tbl_deep_extend("force", opts, test[2])
      Config.setup(opts)

      local orig_plugins = PluginTable.plugins
      PluginTable.plugins = test[3]

      assert(Config.options.auto_plugin_discovery == false)
      assert.equals(test[5], Core.get_plugin_path(test[4]))

      PluginTable.plugins = orig_plugins
    end)
  end
end)

plenary.busted.describe("test lazypath", function()
  local lazy_nix_store_path = "nix/store/hash123-vimplugins-lazy.nvim"
  local default_lazypath = "default/lazypath"
  local tests = {
    { "lazy found in nix store", { ["lazy.nvim"] = lazy_nix_store_path }, lazy_nix_store_path },
    { "lazy not found in nix store", {}, default_lazypath },
  }

  for _, test in ipairs(tests) do
    plenary.busted.it(test[1], function()
      -- would prefer to mock Core.build_plugin_table to return the expected test plugin table,
      -- but can't get that to work at the moment
      local orig_plugins = PluginTable.plugins
      PluginTable.plugins = test[2]

      local opts = { lazypath = default_lazypath }
      Config.setup(opts)

      assert(Config.options.auto_plugin_discovery == false)
      assert.equals(test[3], Core.lazypath())

      PluginTable.plugins = orig_plugins
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
