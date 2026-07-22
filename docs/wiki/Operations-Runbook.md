# Operations Runbook

This page describes the intended operational flows for the `tacos` host.

## Validation Ladder

Use the least invasive step that still validates the change:

1. `tacos-fmt`
2. `tacos-stage`
3. `git -C ~/Projects/nixos-config commit -m "..."`
4. `tacos-eval`
5. `tacos-build`
6. `tacos-switch` only with explicit approval

## Why Commit Before Build

The host sets:

```nix
system.configurationRevision = if (self ? rev) then self.rev else throw "Commit your changes first!";
```

That means:

- uncommitted trees are intentionally rejected for rebuildable state
- a valid Git commit is part of the system identity
- rollback and auditability depend on committed history

## Fast-Path (Daily Driver)

For standard additions (new packages, simple config tweaks), you can safely chain the commands. `tacos-switch` is inherently atomic and will safely abort without mutating the system if evaluation or building fails.

```bash
tacos-fmt && tacos-stage && git -C ~/Projects/nixos-config commit -m "describe the configuration change" && tacos-switch
```

## Complex Logic Flow

When writing custom derivations, doing large refactors, or experimenting, use the explicit validation steps to catch syntax and build errors early before ever attempting to switch:

```bash
tacos-fmt
tacos-stage
git -C ~/Projects/nixos-config commit -m "describe the complex change"
tacos-eval
tacos-build
tacos-switch
```

## Lockfile Recovery

If Nix reports that `flake.lock` changed and committed state is required:

```bash
git -C ~/Projects/nixos-config add flake.lock
git -C ~/Projects/nixos-config commit -m "chore: track updated flake inputs"
```

Then rerun:

```bash
tacos-eval
tacos-build
```

## Cleanup And Old Generations

Cleanup is intentionally destructive and should only be run when the current
system state is known-good and the active configuration revision is trusted.

To purge old generations and reclaim disk space, run the atomic helper:

```bash
tacos-cleanup
```

The system will automatically keep the most recent 10 generations
in the boot menu as a fallback.

Notes:

- this is destructive maintenance
- it should not be bundled into validation helpers
- it should not run automatically during risky migrations

## Safe Expectations

- `tacos-build` can download or realise store paths
- `tacos-switch` can restart services and re-activate units
- `tacos-cleanup` will permanently delete all unreferenced system history
- `tacos-fmt` and `tacos-stage` write to the repository
- only `tacos-status`, `tacos-eval`, and `tacos-validate` are read-only
