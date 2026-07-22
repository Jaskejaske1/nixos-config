# tacos NixOS Configuration

Declarative NixOS flake for the `tacos` workstation.

This repository is operated under a narrow AI model:

- The human owner defines policy, risk tolerance, and architecture.
- Codex is the primary implementation agent inside those boundaries.
- Git history is the control plane for system change.
- Reproducibility and rollback safety are preferred over convenience shortcuts.

## Current Host

- Host: `tacos`
- Platform: `x86_64-linux`
- Nixpkgs channel: `nixos-26.05`
- Desktop: KDE Plasma 6 on SDDM Wayland
- Primary editor workflow: Zed

## Repository Layout

```text
flake.nix                 # Flake inputs and host outputs
hosts/tacos/              # Host-specific identity and hardware state
modules/core/             # Shared base system behavior and tacos helpers
modules/desktop/          # Graphical session and desktop-facing packages
modules/profiles/         # Capability profiles (web, C++, travel, hardware, networking)
docs/wiki/                # In-repo wiki source pages that can be mirrored to GitHub Wiki
AGENTS.md                 # Mandatory rules for coding agents
SKILLS.md                 # Supplemental execution conventions
```

## Active Profiles

- `modules/core/`: boot defaults, locale, Nix settings, Syncthing, Snapper, helper scripts.
- `modules/desktop/`: KDE Plasma 6, PipeWire, Firefox, Zed, Codex CLI, and desktop packages.
- `modules/profiles/dev-web.nix`: Node 24, fnm, PHP 8.3, Composer, PowerShell, Obsidian, terminal tools.
- `modules/profiles/dev-cpp.nix`: GCC 13, CMake, Ninja, SDL3, OpenGL, Wayland, X11, XCB, PipeWire-related dev packages.
- `modules/profiles/net-lab.nix`: Wireshark enablement and group access.
- `modules/profiles/hardware.nix`: serial tooling and `dialout` access.
- `modules/profiles/road-trip.nix`: TLP battery tuning, Intel video decode, and `mpv` defaults.

## `tacos-` Command Model

The helper commands are intentionally atomic. They do not compose hidden steps.

| Command | Purpose | Side-effect class |
| --- | --- | --- |
| `tacos-status` | Show repo path, current revision, and working tree state | `read-only` |
| `tacos-fmt` | Format tracked Nix files | `repo-writing` |
| `tacos-eval` | Read-only `nix eval` of the system derivation | `read-only` |
| `tacos-validate` | Deprecated alias for `tacos-eval` | `read-only` |
| `tacos-stage` | Stage repository changes | `repo-writing` |
| `tacos-wiki` | Publish committed `docs/wiki/` content to the GitHub wiki repo | `remote-writing` |
| `tacos-build` | Non-activating `nix build --no-link` of committed system | `store-writing` |
| `tacos-switch` | Activate the committed system after an explicit prompt | `system-activating` |

Important distinctions:

- `idempotent` does not mean `side-effect-free`.
- `tacos-wiki` clones, commits, and pushes to a remote Git repository.
- `tacos-build` can fetch or realise store paths.
- `tacos-fmt` changes tracked files.
- `tacos-switch` changes live system state and requires explicit approval.

## Syncthing Posture

The current Syncthing policy is local-network only:

- GUI bound to `127.0.0.1:8384`
- `openDefaultPorts = false`
- local LAN discovery enabled
- global discovery disabled
- relays disabled
- NAT traversal disabled

This keeps discovery available on the same LAN while preventing public discovery and relay use.

## Standard Workflow

For standard, low-risk changes, use the fast-path chain:
```bash
tacos-fmt && tacos-stage && git -C ~/Projects/nixos-config commit -m "describe the configuration change" && tacos-switch
```

If you are writing complex logic or need to dry-run a build, use the explicit validation ladder:
```bash
tacos-status
tacos-fmt
tacos-stage
git -C ~/Projects/nixos-config commit -m "describe the configuration change"
tacos-eval
tacos-build
tacos-switch
```

If `docs/wiki/` changed, run `tacos-wiki` after a successful switch so the GitHub wiki matches the activated repository state.

## Guardrails

- Shared modules under `modules/` remain host-blind.
- Host identity belongs under `hosts/tacos/`.
- Dirty-tree rebuilds are intentionally rejected because `system.configurationRevision` depends on committed Git state.
- `programs.nix-ld.enable = true;` is preserved for external dynamically linked binaries.
- Network-facing services default to conservative exposure.

## Documentation Map

- [AGENTS.md](./AGENTS.md): mandatory assistant operating rules
- [SKILLS.md](./SKILLS.md): structural execution conventions
- [Wiki Home](./docs/wiki/Home.md): in-repo wiki landing page source
- [Wiki Commands](./docs/wiki/Tacos-Commands.md): detailed helper command semantics
- [Wiki Operations](./docs/wiki/Operations-Runbook.md): validation, switch, and cleanup runbooks
- [Wiki Architecture](./docs/wiki/Architecture.md): flake and module topology
