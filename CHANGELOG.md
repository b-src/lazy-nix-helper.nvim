# Changelog

## [UNRELEASED]

### Docs

- Add missing `lib` input in recommended nix configuration

## [0.4.0] 2023-12-29

### Features

- Support passing a nix-generated table of plugin names:plugin paths instead of plugin discovery within the plugin
  + This should also mean that Lazy-Nix-Helper will work with nix-installed plugins on a non-NixOS system, but I haven't tested that

### Docs

- Update docs to provide instructions for generating the input plugin table from Nix


## [0.3.0] - 2023-12-27

### Docs

- Update docs regarding plugin discovery limitations
- Add note about plugin display names in the Lazy dashboard
- Add section on alternative tools


## [0.2.0] - 2023-12-26

### Features

- Add config option for friendlier plugin name handling

### Fixes

- Close dangling file handles previously left by nix store lookups

### Docs

- Add NixOS config instructions

### Meta

- Add tests for existing features
- Add makefile target to run test suite
- Run tests in CI
- Add linting and auto-formatting
- Add linting and formatting checks to CI


## [0.1.0] - 2023-12-03

### Features

- Initial functionality. 
 + Scan the nix store (if available) for vim plugin paths
 + Add a function to return the nix store path given a plugin name
 + Add a function to return the nix store path of `Lazy`
 + Add a function to determine if Mason should be enabled
- Add a function to print the discovered plugins table for troubleshooting purposes

### Docs

- Add instructions to bootstrap Lazy-Nix-Helper and update existing plugin configuration
- Add instructions for updating configurations that are using `Mason`
- Vim docs
