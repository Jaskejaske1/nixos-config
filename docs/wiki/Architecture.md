# Architecture

This page describes the active structure of the `tacos` flake.

## Flake Topology

`flake.nix` defines one NixOS configuration:

- `nixosConfigurations.tacos`

Current inputs:

- `nixpkgs` pinned to `nixos-26.05`
- `codex-cli-nix` following the same `nixpkgs`

## Host Boundary

`hosts/tacos/` contains host-specific state:

- hardware configuration
- host name
- state version
- primary user declaration
- configuration revision policy

Shared modules under `modules/` should not reclaim those responsibilities.

## Shared Module Layers

### `modules/core/`

Shared base behavior:

- Nix settings and garbage collection
- boot defaults
- locale and timezone
- NetworkManager and firewall baseline
- Snapper and Btrfs maintenance
- Syncthing configuration with local LAN discovery enabled while public discovery, relays, and NAT traversal stay disabled
- `zramSwap` and `fwupd` firmware management
- helper scripts such as `tacos-status`, `tacos-fmt`, `tacos-eval`, `tacos-build`, `tacos-switch`, `tacos-update`, and `tacos-wiki`

### `modules/desktop/`

Graphical workstation layer:

- KDE Plasma 6 import via `modules/desktop/kde.nix`
- SDDM Wayland session
- Belgian keyboard layout
- PipeWire audio stack
- desktop-facing packages such as Firefox, Chromium, Discord, Zed, btop, and Codex CLI

### `modules/profiles/`

Capability modules:

- `dev-web.nix`: Node 24, fnm, PHP 8.3, Composer, PowerShell, Obsidian, terminal tools
- `dev-cpp.nix`: GCC 13, CMake, Ninja, SDL3, Wayland, X11, XCB, GL, PipeWire dev packages
- `dev-direnv.nix`: Direnv and nix-direnv enablement for project-scoped shell environments
- `net-lab.nix`: Wireshark enablement and group access
- `hardware.nix`: `picocom` and `dialout` access
- `road-trip.nix`: TLP battery profile, Intel media driver, and `mpv` defaults
- `vpn-mullvad.nix`: Mullvad VPN daemon and GUI autostart

## Repository Intent

The system is optimized for:

- a Git-first NixOS workflow
- Zed-centric development
- modern web and C++ project support
- conservative live-system mutation rules
- AI-assisted implementation under explicit policy control
