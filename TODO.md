# TODO

## Core Functionality

- [x] naive implementation of nix store plugin discovery
- [ ] make plugin discovery work in a non-nixos environment with nix installed
- [ ] more robust implementation of nix store plugin discovery
- [ ] find plugins from all possible package groups, not just `vimplugin` and `lua5.1`
- [x] get nix store plugin path given a plugin name
- [x] can plugin names be made friendlier in configuration without risking collisions?
        can we let the user supply "my-plugin" while also checking the store for
        e.g. "My-Plugin", "my_plugin", "my-plugin.nvim"...
- [x] figure out how to play nicely with mason
- [x] see if there's a way to improve plugin name display in the lazy dashboard (i.e. plugin name, not full nix store path)
        there is not. see the `Configuration of Other Plugins` section in the README for more details

## Configuration

- [x] instructions to bootstrap lazy-nix-helper
- [x] instructions for updating existing plugin config
- [x] come up with a better way to provide lazy-nix-helper's own nix store path than manually supplying it
- [x] instructions for mason-compatible config
- [ ] determine lazy-nix-helper's requirements: neovim version, nixos version, etc.

## Installation

- [ ] package plugin and get it merged to nixpkgs

## Meta

- [x] write some tests
- [x] provide makefile target to run all tests locally
- [x] run tests in CI
- [x] add auto formatting
- [x] add formatting check to CI
- [x] add linting
- [x] add linting to CI

