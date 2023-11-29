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

TODO: instructions for configuring this plugin.

### Configuration of Other Plugins

TODO: instructions for updating other plugin configuration.

### Mason

TODO: figure out how to play nicely with Mason included in the configuration and add instructions here.

## Known Limitations

Lazy-Nix-Helper can't currently find plugins installed by Nix on non-NixOS platforms.

## Troubleshooting

TODO: function to show plugins found by Lazy-Nix-Helper.
TODO: instructions for debug logging.
TODO: health check?


