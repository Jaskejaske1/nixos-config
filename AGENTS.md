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

## Operating Model

This repository is managed under a narrow AI operating model.

- The human owner defines system policy, architectural direction, and approval thresholds.
- The coding assistant is the primary implementation agent inside those rules.
- Git history is the control plane for system change.
- Declarative configuration is preferred over ad hoc imperative mutation.
- The assistant must optimize for transparency, auditability, and rollback safety rather than autonomy for its own sake.

## Execution Boundaries

### Changes the Assistant May Make Without Prior Approval

- Refactor repository structure to match documented conventions.
- Fix Nix syntax issues, evaluator warnings, deprecations, and `nixd` diagnostics.
- Remove unused arguments, unused imports, and other low-risk configuration noise.
- Improve comments, naming, formatting, and module organization.
- Add or adjust validation commands that do not activate the system configuration.
- Update documentation so it matches the real repository behavior.

### Changes That Always Require Explicit Approval

- Running `nixos-rebuild switch`, `boot`, `test`, or any command that activates a new system state.
- Changing bootloader behavior, disk layout, swap layout, filesystems, impermanence strategy, or hardware-specific boot logic.
- Adding, removing, or rotating secrets, credentials, SSH keys, tokens, or age/sops material.
- Opening network-facing services, changing firewall posture, or exposing new remote access paths.
- Introducing virtualization, container, or sandboxing changes that materially expand system privilege boundaries.
- Running destructive cleanup, deleting generations, or garbage-collecting the store outside a clearly approved maintenance step.
- Installing or enabling software whose purpose is unclear, high-risk, invasive, or unrelated to the requested task.

## Package and Service Policy

### Package Additions

- Prefer packages that clearly support the declared workstation workflow, NixOS management, or approved user requests.
- Prefer Zed-compatible tooling over editor ecosystems that pull the setup toward VS Code or terminal-only workflows.
- Keep the default system package set intentionally small; remove tools that are no longer justified.
- When adding packages, prefer well-maintained nixpkgs packages or explicitly declared flake inputs over opaque one-off installation methods.

### Service Changes

- Prefer disabled-by-default network exposure.
- New background services, timers, or daemons must have a clear operational purpose and should be documented in the same change.
- Shared modules under `modules/` must remain host-blind; host-specific services or identity settings belong under `hosts/`.

## Secrets and Sensitive Data Policy

- Do not commit plaintext secrets, credentials, recovery codes, tokens, or private keys.
- Do not embed secrets directly in Nix files, shell scripts, or documentation.
- If secret material is needed, stop and require an explicit user-approved secret management approach before proceeding.
- Treat machine identity, authentication material, and remote access configuration as sensitive even if not formally secret.

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

### Validation Ladder

Use the least invasive step that can still validate the change:

1. Format the relevant Nix files with `nixfmt`.
2. Run non-activating evaluation such as `nix eval` or other read-only checks.
3. Commit the change set required for evaluation or rebuild.
4. Run build-oriented validation before activation when practical.
5. Activate the configuration only after explicit approval.

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

## Repository Structure Policy

- `modules/core/` is for shared base system behavior such as locale, Nix settings, boot defaults, and maintenance-safe platform settings.
- `modules/desktop/` is for graphical environment, userland workstation tooling, and desktop-facing services.
- `hosts/<name>/` is for machine-specific imports, host names, hardware configuration, and pinned state version.
- Do not move host-specific values back into shared modules.
- Keep modules small, focused, and free of unused parameters.

## Assistant Behavior Summary

When operating in this repository, assistants should:

- Work as an implementation agent, not as an unsupervised operator.
- Commit relevant changes before rebuilds.
- Commit `flake.lock` updates when flake input changes require it.
- Fix warnings instead of tolerating them.
- Keep Nix modules clean and minimal.
- Escalate for approval before any live system activation or destructive maintenance.
- Avoid unsafe cleanup until the system is known-good.
- Preserve Zed-oriented workflow assumptions.
- Respect the need for `nix-ld` when external binaries are involved.
