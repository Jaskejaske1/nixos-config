# AGENTS.md

## Purpose

This document defines the operating rules for terminal-based coding assistants working in this repository. These instructions govern how assistants should modify, validate, and maintain the NixOS configuration in `~/Projects/nixos-config`.

Treat the requirements below as mandatory unless the user explicitly overrides them.

## Repository Scope

- Repository: `~/Projects/nixos-config`
- Platform: NixOS configuration managed through flakes
- Primary editor environment: Zed
- Primary concern: preserve reproducibility and avoid unsafe system mutations

## Core Operating Principles

- Prefer safe, reversible changes.
- Keep the repository in a buildable, reproducible state.
- Do not ignore warnings from the Nix evaluator, `nixos-rebuild`, or language tooling.
- Make changes in a way that respects the repository's Git-driven rebuild workflow.

## GitOps Workflow Requirements

This repository follows a strict commit-before-build workflow.

### Commit Before Rebuild

- Stage and commit configuration changes before running any system rebuild.
- The flake evaluation relies on committed Git state via `self.rev`.
- If the working tree is dirty, rebuilds may intentionally fail.

Required workflow:

```bash
git add .
git commit -m "describe the configuration change"
```

Run rebuild commands only after the relevant changes are committed.

### Lockfile Handling

- Changes to `flake.nix`, especially input additions or modifications, may update `flake.lock`.
- If evaluation or rebuild fails with an error instructing you to commit changes first and the failure references `flake.lock`, commit the updated lockfile immediately before retrying.

Example recovery flow:

```bash
git add flake.lock
git commit -m "chore: track updated flake inputs"
```

Then rerun the rebuild command.

## Diagnostics and Code Hygiene

Keep the tree free of avoidable warnings and language-server noise.

### Zed and `nixd` Diagnostics

- Pay attention to diagnostics surfaced by Zed and the `nixd` language server.
- Remove unused top-level function parameters in simple modules.
- Replace broad unused argument sets such as `{ config, pkgs, ... }:` with a narrower set or `{ ... }:` when those bindings are not used.
- Remove unused `with` expressions entirely.

### Rebuild Warnings

- Do not ignore deprecation notices or structural warnings emitted by `nixos-rebuild`.
- When the CLI reports a required syntax or API migration, update the code immediately as part of the same change.

Example deprecation migration:

```nix
# Deprecated
input-flake.packages.${pkgs.system}.default

# Preferred
input-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
```

## Rebuild and Mutation Safety

- Assume rebuilds are system mutations and treat them carefully.
- Do not rebuild against uncommitted configuration changes.
- Do not leave the repository in a partially migrated state after addressing evaluator warnings.

## Storage Maintenance Policy

Nix store cleanup should be handled conservatively.

### Stability Requirement

- Do not delete old generations while the system is in the middle of a major upgrade, risky migration, or otherwise unverified state.
- Only perform cleanup after the current configuration has been validated as stable.

### Purge Sequence

Once the system is confirmed stable and the reported configuration revision is a valid Git SHA, use this cleanup sequence:

```bash
# Remove system generations older than 1 day
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +1

# Collect unreferenced store paths
sudo nix-store --gc
```

## Environment and Platform Expectations

### Editor Assumptions

- Prefer solutions compatible with Zed.
- Do not recommend or introduce heavyweight Electron-based editor workflows such as VS Code unless the user explicitly asks for them.
- Do not steer the setup toward terminal-only editor workflows such as Neovim unless requested.

### Runtime Interoperability

- Assume generic dynamically linked Linux binaries may fail on this system unless compatibility support is enabled.
- Preserve or ensure:

```nix
programs.nix-ld.enable = true;
```

Use this when external unpatched binaries need to run on the host.

## Assistant Behavior Summary

When operating in this repository, assistants should:

- Commit relevant changes before rebuilds.
- Commit `flake.lock` updates when flake input changes require it.
- Fix warnings instead of tolerating them.
- Keep Nix modules clean and minimal.
- Avoid unsafe cleanup until the system is known-good.
- Preserve Zed-oriented workflow assumptions.
- Respect the need for `nix-ld` when external binaries are involved.
