# Lazy-Nix-Helper

A neovim plugin allowing a single neovim configuration with the Lazy plugin manager to be used on NixOS and other platforms. This plugin provides:

 - On NixOS:
   + plugins(/LSP servers/DAPs/linters/formatters?) installed via Nix
   + configuration of plugins via Lazy
   + lazy loading of plugins via Lazy
 - On other platforms:
   + the same neovim configuration files you use on NixOS
   + plugins(/LSP servers/DAPs/linters/formatters?) installed via Lazy(/Mason?) as normal
   + configuration via Lazy as normal
   + lazy loading of plugins via Lazy as normal


## Motivation

When I switched to NixOS I had an existing neovim configuration using the Lazy plugin manager. Home Manager in NixOS provides it's own way to manage installation and configuration of neovim plugins, but migrating would be a heavy lift. If I could run NixOS everywhere, I would probably have spent the effort to migrate. I'm not so lucky, so this plugin was created to let me have a portable neovim config that works nicely on and off NixOS.

## Compromise

Normally when using Lazy plugins are configured with a github plugin URL, which Lazy uses to download and install the plugin. However, Lazy also provides a `dir` configuration option for the installation of local plugins. By setting the `dir` value for each plugin to its location in the nix store, we are able to let Nix manage the installation of our plugins, while letting Lazy manage the configuration.

## How it works

Lazy-Nix-Helper searches the nix store for all installed vim plugins and builds a table associating each plugin's name with its nix store path. The `get_plugin_path()` function will return the nix store path corresponding to a given plugin name.

## Requirements

TODO: 
 - compatible neovim versions?
 - nixos compatibility? 
 - dependencies?
 - neovim io.popen() not available on all platforms


## Configuration and Installation

### Lazy-Nix-Helper Configuration

**Bootstrapping Lazy Nix Helper's Nix Store Path**

The nix store path for the Lazy-Nix-Helper plugin itself must be bootstrapped. We can't rely on the built in functionality to find the nix store path because the plugin hasn't been loaded yet, and the plugin can't be loaded without its nix store path, etc.

The config instructions below have you manually set the nix store path for lazy nix helper in your config. This is a pain and will break every time you update Lazy Nix Helper.

**Loading Before Lazy **

Because Lazy will resolve plugin configurations before loading any plugins, we must load lazy nix helper manually before loading lazy.

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

To update this configuration to work with Lazy Nix Helper, we will:
 - bootstrap Lazy Nix Helper
 - add Lazy Nix Helper to the vim runtime
 - call the Lazy Nix Helper `setup()` function
 - set the lazypath using Lazy Nix Helper


Update the configuration as follows:
```Lua
-- manually set this to your nix store path for lazy nix helper. TODO: improve
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

-- add the Lazy Nix Helper plugin to the vim runtime
vim.opt.rtp:prepend(lazy_nix_helper_path)

-- call the Lazy Nix Helper setup function. pass a default lazypath for non-nix systems as an argument
local non_nix_lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
require("lazy-nix-helper").setup(non_nix_lazypath)

-- get the lazypath from Lazy Nix Helper
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
  dir = require("lazy-nix-helper").get_plugin_path("my-cool-plugin"),
  ...
}
```

Don't forget to update each plugin's dependencies as well

```Lua
{
  repo/my-cool-plugin.nvim,
  dir = require("lazy-nix-helper").get_plugin_path("my-cool-plugin"),
  dependencies = {
    {
      repo/my-cool-plugins-dep.nvim,
      dir = require("lazy-nix-helper").get_plugin_path("my-cool-plugins-dep"),
      ...
    },
    ...
  },
  ...
}
```

The `get_plugin_path` function is case sensitive as well as sensitive to the difference between `-` and `_`. Be careful that you are matching the convention used by each plugin as you configure its `get_plugin_path` call.

### Mason

TODO: figure out how to play nicely with Mason included in the configuration and add instructions here.

## Known Limitations

Lazy-Nix-Helper can't currently find plugins installed by Nix on non-NixOS platforms.

## Troubleshooting

TODO: function to show plugins found by Lazy-Nix-Helper?
TODO: instructions for debug logging?
TODO: health check?

