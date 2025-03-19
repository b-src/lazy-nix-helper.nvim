# Lazy-Nix-Helper

A neovim plugin allowing a single neovim configuration with the Lazy plugin manager to be used on NixOS and other platforms. This plugin makes the following arrangement possible:

 - On NixOS:
   + plugins (and LSP servers/DAP servers/linters/formatters) installed via Nix
   + configuration of plugins via Lazy
   + lazy loading of plugins via Lazy
 - On other platforms:
   + the same neovim configuration files you use on NixOS
   + plugins installed via Lazy installed via Lazy as normal
   + LSP servers/DAP servers/linters/formatters installed via Mason as normal
   + configuration via Lazy as normal
   + lazy loading of plugins via Lazy as normal


## Motivation

When I switched to NixOS I had an existing neovim configuration using the Lazy plugin manager. Home-Manager for NixOS provides it's own way to manage installation and configuration of neovim plugins, but migrating would be a heavy lift. If I could run NixOS everywhere, I would probably have spent the effort to migrate. I'm not so lucky, so this plugin was created to let me have a portable neovim config that works nicely on and off NixOS.

## Compromise

Normally when using Lazy plugins are configured with a github plugin URL, which Lazy uses to download and install the plugin. However, Lazy also provides a `dir` configuration option for the installation of local plugins. By setting the `dir` value for each plugin to its location in the nix store, we are able to let Nix manage the installation of our plugins, while letting Lazy manage the configuration.

## How it works

Lazy-Nix-Helper accepts a table mapping plugin names to nix-store plugin paths as input. The `get_plugin_path()` function will return the nix store path corresponding to a given plugin name if the path exists on the system.

## Requirements

Note: the docs list neovim version >= 0.9.0 as a requirement. It will probably work for much earlier versions, but that's all I've tested it on so far.

TODO: 
 - compatible neovim versions?
 - nixos compatibility? 
 - dependencies?
 - neovim io.popen() not available on all platforms

## Installation

### NixOS

I haven't packaged Lazy-Nix-Helper on NixOS yet, so for now you'll have to package it in your config manually. An example is shown in the NixOS Configuration section below. Additional info can be found here:
https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/vim.section.md#what-if-your-favourite-vim-plugin-isnt-already-packaged-what-if-your-favourite-vim-plugin-isnt-already-packaged

### Other Platforms

The configuration instructions below include code that will install Lazy-Nix-Helper from GitHub when the given nix store path for Lazy-Nix-Helper does not exist.

## Configuration

### Lazy-Nix-Helper Configuration

**Default Config**
```Lua
{
  lazypath = nil,
  friendly_plugin_names = false,
  auto_plugin_discovery = false,
  input_plugin_table = {}
}
```

**Config Options**
 - `lazypath`: the default lazypath. must be set in plugin config
 - `friendly_plugin_names`: when set to `true` provides less-strict plugin name matching for get_plugin_path():
   + not case sensitive
   + treats `-` and `_` as identical
   + add or subtracts `.nvim` from the plugin name as needed

   if there is a plugin name collision with these rules applied then lazy-nix-helper will thrown an error. in that case you will have to set this option to false and match plugin names exactly.

   it is recommended to keep this set to false. this was a more relevant feature when `auto_plugin_discovery` was the only method and the plugin names weren't always clear. now that the plugin accepts an `input_plugin_table` generated by your nix config, it is recommended to reference the plugin names as output by your nix builds. 
 - `auto_plugin_discovery`: when set to `true` enables the automatic plugin discovery originally included in Lazy-Nix-Helper. the automatic plugin discovery is a nix anti-pattern and only works for a subset of nix/nixos use cases and config arrangements. since some neovim plugin packages have been moved to different package sets this will no longer work for every plugin. this option has been left in place to let early adopters of Lazy-Nix-Helper keep their original configuration, but it should be set to `false` for all new configurations
 - `input_plugin_table`: the plugin table mapping plugin names to plugin paths generated by your nix config. instructions for generating this table are provided in the NixOS Configuration section

**Lazy-Nix-Helper's own Nix Store Path**

The nix store path for the Lazy-Nix-Helper plugin itself cannot be provided by Lazy-Nix-Helper. We can't rely on the built in functionality to find the nix store path because the plugin hasn't been loaded yet, and the plugin can't be loaded without its nix store path, etc.

The recommended way to deal with this is to move your `init.lua` configuration into `programs.neovim.extraLuaConfig`. Then the nix-store path of Lazy-Nix-Helper can be provided with a variable. See the NixOS Configuration section for more details.

**Loading Before Lazy**

Because Lazy will resolve plugin configurations before loading any plugins, we must load Lazy-Nix-Helper manually before loading lazy.

**Updating init.lua**

These instructions will assume you are already installing and loading Lazy with the instructions provided by the Lazy README. If you are doing something different then you may have to adapt these instructions to fit your own config

The Lazy README recommends adding the following to your `init.lua`:

```Lua
-- set lazypath variable to the path where the Lazy plugin will be installed on your system
-- if Lazy is not already installed there, download and install it
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
-- add the Lazy plugin to the vim runtime
vim.opt.rtp:prepend(lazypath)

-- set mapleader before loading lazy if applicable
vim.g.mapleader = " "

-- install and load plugins from your configuration
require("lazy").setup(plugins, opts)
```

To update this configuration to work with Lazy-Nix-Helper, we will:
 - bootstrap Lazy-Nix-Helper
 - add Lazy-Nix-Helper to the vim runtime
 - call the Lazy-Nix-Helper `setup()` function
 - set the lazypath using Lazy-Nix-Helper


Update the configuration as follows:
```Lua
-- THIS PLUGIN LIST SHOULD BE GENERATED BY YOUR NIX CONFIG. See the NixOS Configuration section for more details on plugins table and lazy_nix_helper_path
local plugins = {
 ["plugin-name.nvim"] = "nix/store/hash1234-vimplugin-plugin-name.nvim",
 ...
}

local lazy_nix_helper_path = <lazy_nix_helper/nix/store/path>

-- if we are not on a nix-based system, bootstrap lazy_nix_helper in the same way lazy is bootstrapped
if not vim.loop.fs_stat(lazy_nix_helper_path) then
  lazy_nix_helper_path = vim.fn.stdpath("data") .. "/lazy_nix_helper/lazy_nix_helper.nvim"
  if not vim.loop.fs_stat(lazy_nix_helper_path) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/b-src/lazy_nix_helper.nvim.git",
      lazy_nix_helper_path,
    })
  end
end

-- add the Lazy-Nix-Helper plugin to the vim runtime
vim.opt.rtp:prepend(lazy_nix_helper_path)

-- call the Lazy-Nix-Helper setup function. pass a default lazypath for non-nix systems as an argument
local non_nix_lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
require("lazy-nix-helper").setup({ lazypath = non_nix_lazypath, input_plugin_table = plugins })

-- get the lazypath from Lazy-Nix-Helper
local lazypath = require("lazy-nix-helper").lazypath()
-- the rest of the configuration is unchanged
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
-- add the Lazy plugin to the vim runtime
vim.opt.rtp:prepend(lazypath)

-- set mapleader before loading lazy if applicable
vim.g.mapleader = " "

-- install and load plugins from your configuration
require("lazy").setup(plugins, opts)
```

### Configuration of Other Plugins

To provide nix store paths to the rest of the plugins in your configuration, update their configuration as in this example

```Lua
{
  repo/my-cool-plugin.nvim,
  dir = require("lazy-nix-helper").get_plugin_path("my-cool-plugin.nvim"),
  ...
}
```

Don't forget to update each plugin's dependencies as well

```Lua
{
  repo/my-cool-plugin.nvim,
  dir = require("lazy-nix-helper").get_plugin_path("my-cool-plugin.nvim"),
  dependencies = {
    {
      repo/my-cool-plugins-dep,
      dir = require("lazy-nix-helper").get_plugin_path("my-cool-plugins-dep"),
      ...
    },
    ...
  },
  ...
}
```

### Mason

Mason is a package manager for LSP servers, DAP servers, linters, and formatters. Just like plugin management with Lazy, this conflicts with Nix. The easiest way to keep mason in your config on non-Nix platforms while disabling it on NixOS is to use the provided `mason_enabled` function to conditionally enable Mason.

This will require you to separately declare all your LSP servers etc. in your NixOS config, but you were doing that already, right?

There are two parts to this:
 1. disabling the `mason` (and `mason-lspconfig`) plugins
 2. checking that `mason` (and `mason-lspconfig`) are enabled before they are used elsewhere in your config

**Conditionally enabling mason**

Here's an example mason configuration as a dependency of `nvim-lspconfig`. Notice that we are using `mason_enabled` to conditionally enable both `mason` and `mason-lspconfig`

```Lua
{
  "neovim/nvim-lspconfig",
  dir = require("lazy-nix-helper").get_plugin_path("nvim-lspconfig"),
  dependencies = {
    {
      "williamboman/mason.nvim",
      enable = require("lazy-nix-helper").mason_enabled(),
      ...
    },
    {
      "williamboman/mason-lspconfig.nvim",
      enable = require("lazy-nix-helper").mason_enabled(),
      ...
    },
    ...
  },
  ...
}
```

Note that specifying the `dir` parameter is not necessary here since these plugins will be disabled in NixOS. 

**Conditionally calling mason**

This part is harder to give examples for because there are a lot of ways you could be setting this up.

I based my original neovim configuration on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim/tree/master), which had checks that `mason` and `mason-lspconfig` were enabled already built again. This was before they migrated to using Lazy, and it looks like this has changed sense.

Some general advice:

 - You can still use the `mason_enabled()` function to gate `mason` or `mason-lspconfig` calls in your configuration
 - Make sure that `lsp-config.setup()` function is still called for each server

After making these changes in my own config LSP servers were working for me on NixOS.

**Caveat for Linters and Formatters**

In my own config I don't use linters or formatters provided by mason. I prefer to handle that on a per-project basis or use tools provided by the language. I haven't tested this plugin with a configuration that includes linters or formatters, and can't confirm that they work with this setup.

## NixOS Configuration

There are a lot of different ways you might set up your NixOS configuration. This section will give configuration examples using home-manager. You may need to adapt this to fit your own system configuration.

The necessary components are:
 1. Package lazy-nix-helper yourself. See these instructions for additional information
      https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/vim.section.md#what-if-your-favourite-vim-plugin-isnt-already-packaged-what-if-your-favourite-vim-plugin-isnt-already-packaged
 2. Put your existing `init.lua` within `programs.neovim.extraLuaConfig`.
 3. Update your `init.lua` to provide the nix store path of Lazy-Nix-Helper
 4. Generate the plugins table
 5. Include the rest of your config files with `xdg.configFile`.

`neovim.nix` module:
```Nix
{ pkgs, config, lib, ... }:

let
  lazy-nix-helper-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "lazy-nix-helper.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "b-src";
      repo = "lazy-nix-helper.nvim";
      rev = "<git commit hash>";
      hash = "<sha256 of archive of git commit>";
    };
  };

  sanitizePluginName = input:
  let
    name = lib.strings.getName input;
    vimplugin_removed = lib.strings.removePrefix "vimplugin-" name;
    luajit_removed = lib.strings.removePrefix "luajit2.1-" vimplugin_removed
    lua5_1_removed = lib.strings.removePrefix "lua5.1-" luajit_removed;
    result = lib.strings.removeSuffix "-scm" lua5_1_removed;
  in result;

  pluginList = plugins: lib.strings.concatMapStrings (plugin: "  [\"${sanitizePluginName plugin.name}\"] = \"${plugin.outPath}\",\n") plugins;

in
  {
    xdg.configFile."nvim/lua" = {
      source = ./neovim_config/lua;
      recursive = true;
    };

    programs.neovim = {
      enable = true;
      ...
      extraPackages = with pkgs; [
        <lsps, etc.>
      ];
      plugins = with pkgs.vimPlugins; [
          lazy-nix-helper-nvim
          lazy-nvim
          <other plugins>
      ];
      extraLuaConfig = ''
        local plugins = {
        ${pluginList config.programs.neovim.plugins}
        }
        local lazy_nix_helper_path = "${lazy-nix-helper-nvim}"
        if not vim.loop.fs_stat(lazy_nix_helper_path) then
          lazy_nix_helper_path = vim.fn.stdpath("data") .. "/lazy_nix_helper/lazy_nix_helper.nvim"
          if not vim.loop.fs_stat(lazy_nix_helper_path) then
            vim.fn.system({
              "git",
              "clone",
              "--filter=blob:none",
              "https://github.com/b-src/lazy_nix_helper.nvim.git",
              lazy_nix_helper_path,
            })
          end
        end

        -- add the Lazy Nix Helper plugin to the vim runtime
        vim.opt.rtp:prepend(lazy_nix_helper_path)

        -- call the Lazy Nix Helper setup function
        local non_nix_lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
        local lazy_nix_helper_opts = { lazypath = non_nix_lazypath, input_plugin_table = plugins }
        require("lazy-nix-helper").setup(lazy_nix_helper_opts)

        -- get the lazypath from Lazy Nix Helper
        local lazypath = require("lazy-nix-helper").lazypath()
        if not vim.loop.fs_stat(lazypath) then
          vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release
            lazypath,
          })
        end
        vim.opt.rtp:prepend(lazypath)

        <additional config in init.lua>
      '';
    };
  }
```

### A Note on dotfiles

After moving your `init.lua` directly into your NixOS config and sourcing the rest of your dotfiles within your NixOS config, you should use the built output in `~/.config/nvim` as the source for sharing your dotfiles with a non-NixOS system.

## Known Limitations

I have not tested Lazy-Nix-Helper with:
 - Nix-installed neovim/plugins on a non-NixOS system
 - Nix-darwin


## Alternatives

Besides Lazy-Nix-Helper there are other tools and strategies you might choose to manage your neovim configuration under NixOS:

### Nix-based solutions
 - [Home-Manager](https://nix-community.github.io/home-manager/) provides options for installing and configuring neovim plugins
 - [nixCats](https://github.com/BirdeeHub/nixCats-nvim/) is a neovim package manager written in Nix. Insteady of "nixifying" your config, use Nix to manage your plugin installation and Lua for configuration
 - [NixVim](https://github.com/nix-community/nixvim/) is a neovim distribution built around Nix modules. It provides nix-style configuration options for every neovim configuration option as well as options for many plugins
 - [nvf](https://github.com/NotAShelf/nvf/) is a flake-based neovim configuration framework

 ### Non-nix
 - Using your existing config as-is. Depending on how complicated your current config is and what it includes, you may be able to copy your dotfiles and have everything work out of the box. The main downside is that you lose the reproducability benefits of nix by using a different package manager

## Troubleshooting

### How do I check which path a plugin is loaded from?

Use the `:Lazy` command to open the Lazy dashboard. The source directory is listed for each plugin

### How do I check the plugin list that was supplied to Lazy-Nix-Helper?

Run the `list_input_plugins` function manually: `lua require("lazy-nix-helper").list_input_plugins()`

### How do I check which plugins were found on the system by Lazy-Nix-Helper? 

Run the `list_discovered_plugins` function manually: `lua require("lazy-nix-helper").list_discovered_plugins()`

### How do I check which path Lazy-Nix-Helper has found for a plugin?

Run the `get_plugin_path` function manually: `:lua print(require("lazy-nix-helper").get_plugin_path("<plugin-name>"))`

### I don't think Lazy-Nix-Helper is correctly detecting when I'm on NixOS

Run the `print_environment_info`  function manually to see:
 - if Lazy-Nix-Helper thinks you're on NixOS or not
 - if Lazy-Nix-Helper thinks nix-store is installed or not (only relevant for legacy automatic plugin discovery)

`lua require("lazy-nix-helper").print_environment_info()`

## Development

### Requirements

Running the automated tests requires [Plenary](https://github.com/nvim-lua/plenary.nvim)

The test setup script will automatically download plenary into the `test_dependencies` directory

### Running tests

From the repo root, run `make test` to run the full suite of tests.

### Linting and auto-formatting

Linting requires [Luacheck](https://github.com/mpeterv/luacheck)

Auto-formatting requires [Stylua](https://github.com/JohnnyMorganz/StyLua)

`make lint` will run both auto-formatting and linting.

`make format` will run only auto-formatting.

`make check` will run only linting.
