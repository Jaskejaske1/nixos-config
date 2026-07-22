# Tacos Commands

This page is the canonical command reference for the repository helper scripts.

## Design Goal

The `tacos-` helpers are intentionally atomic.

They are not a hidden pipeline.
Each command owns one responsibility so that automation, humans, and agents can reason about side effects precisely.

## Classification

Use these categories exactly when documenting or automating behavior:

- `read-only`: safe to rerun, does not mutate the repository or activate the system
- `repo-writing`: mutates tracked files or the Git index
- `store-writing`: may fetch or realise Nix store paths without activating the system
- `system-activating`: changes the live system state

## Command Matrix

| Command | What it does | Hidden formatting? | Hidden staging? | Hidden build? | Side-effect class |
| --- | --- | --- | --- | --- | --- |
| `tacos-status` | Prints repo path, Git revision, and working tree state | No | No | No | `read-only` |
| `tacos-fmt` | Formats tracked Nix files | Yes, explicitly | No | No | `repo-writing` |
| `tacos-eval` | Runs read-only `nix eval` for the tacos system derivation | No | No | No | `read-only` |
| `tacos-validate` | Deprecated alias for `tacos-eval` | No | No | No | `read-only` |
| `tacos-stage` | Stages repository changes with `git add .` | No | Yes, explicitly | No | `repo-writing` |
| `tacos-update` | Updates flake inputs and stages `flake.lock` | No | Yes, explicitly | No | `repo-writing` |
| `tacos-wiki` | Publishes committed `docs/wiki/` content to GitHub wiki repo | No | No | No | `remote-writing` |
| `tacos-build` | Runs `nix build --no-link` against the committed system | No | No | Yes, explicitly | `store-writing` |
| `tacos-switch` | Prompts, then runs `sudo nixos-rebuild switch` against the committed system | No | No | No | `system-activating` |

## Important Distinctions

### Read-only is not the same as idempotent

- `tacos-status`, `tacos-eval`, and `tacos-validate` are read-only.
- `tacos-build` is usually operationally idempotent, but it is not read-only because it can fetch or realise store paths.

### Formatting is a write

- `tacos-fmt` is not safe to call if you must preserve an untouched working tree.
- After the first successful run it should converge, but it still changes files when formatting is needed.

### Staging is a write

- `tacos-stage` mutates the Git index.
- Repeating it on the same tree usually converges, but it is still not side-effect-free.

### Switching is always a live mutation

- `tacos-switch` can restart services, reload units, and change the active system generation.
- Even if the target generation is already built, it is still treated as a system mutation.

## Recommended Usage

### Inspect state

```bash
tacos-status
```

### Validate a change set

```bash
tacos-fmt
tacos-stage
git -C ~/Projects/nixos-config commit -m "describe the configuration change"
tacos-eval
tacos-build
```

### Activate a known-good commit

```bash
tacos-switch
```

Only do this after explicit approval.

## Deprecated Alias

`tacos-validate` exists for compatibility only.

- Do not introduce it into new scripts
- Do not document it as the preferred path
- Prefer `tacos-eval` in all new automation
