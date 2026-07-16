# Home

This wiki documents the live operating model for the `tacos` NixOS flake.

It is stored in-tree under `docs/wiki/` as source material. It does not publish itself to GitHub Wiki automatically.

## What This Repository Is

`tacos` is a single-host NixOS flake managed with a Git-first workflow and a narrow AI operating model:

- The owner defines policy and approval thresholds.
- Codex performs implementation work inside those boundaries.
- Git commits are treated as the source of truth for rebuildable system state.
- Declarative configuration is preferred over imperative machine mutation.

## Current Platform Snapshot

- Host: `tacos`
- System: `x86_64-linux`
- Channel: `nixos-26.05`
- Desktop: KDE Plasma 6 on SDDM Wayland
- Editor baseline: Zed

## Read This First

- [Tacos Commands](./Tacos-Commands.md)
- [Operations Runbook](./Operations-Runbook.md)
- [Architecture](./Architecture.md)

## Core Rules

- Build and switch only from committed Git state.
- Treat `tacos-build` as non-activating but not side-effect-free.
- Treat `tacos-switch` as a live system mutation.
- Keep shared modules host-blind.
- Keep network exposure explicit and conservative.

## Quick Workflow

```bash
tacos-status
tacos-fmt
tacos-stage
git -C ~/Projects/nixos-config commit -m "describe the configuration change"
tacos-eval
tacos-build
```

Run `tacos-switch` only after explicit approval to activate the committed configuration.
