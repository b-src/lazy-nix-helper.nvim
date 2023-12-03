# TODO

## Core Functionality

- [x] naive implementation of nix store plugin discovery
- [ ] make plugin discovery work in a non-nixos environment with nix installed
- [ ] more robust implementation of nix store plugin discovery
- [ ] find plugins from all possible package groups, not just `vimplugin` and `lua5.1`
- [x] get nix store plugin path given a plugin name
- [ ] can plugin names be made friendlier in configuration without risking collisions?
        can we let the user supply "my-plugin" while also checking the store for
        e.g. "My-Plugin", "my_plugin", "my-plugin.nvim"...
- [ ] figure out how to play nicely with mason
- [ ] see if there's a way to improve plugin name display in the lazy dashboard (i.e. plugin name, not full nix store path)

## Configuration

- [x] instructions to bootstrap lazy-nix-helper
- [x] instructions for updating existing plugin config
- [ ] come up with a better way to provide lazy-nix-helper's own nix store path than manually supplying it
- [ ] instructions for mason-compatible config
- [ ] determine lazy-nix-helper's requirements: neovim version, nixos version, etc.

## Installation

- [ ] package plugin and get it merged to nixpkgs

## Meta

- [ ] write some tests
