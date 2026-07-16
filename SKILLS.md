# SKILLS.md

## Codex Structural Execution Rules

### 1. Mandatory Directory Segmentation
All shared, reusable configurations must be segmented away from the flat repository root into explicitly named functional subdirectories:
- `modules/core/` -> Time zones, bootloaders, system maintenance timers, locale arrays.
- `modules/desktop/` -> GNOME, GDM display properties, keymaps, global package lists.
- `hosts/tacos/` -> Machine-specific hardware configs, host names, state versions, filesystems.

### 2. Parameter Extraction Protocol
- Structural modules must remain entirely host-blind. 
- Machine-specific strings like `networking.hostName` or `system.stateVersion` must live exclusively inside the specific host profiles under the `hosts/` block.

### 3. GitOps Validation Sequence
Before running any build or activation step, Codex must follow the atomic helper workflow:
1. Run `tacos-fmt` for intentional formatting changes.
2. Stage changes with `tacos-stage`.
3. Commit explicitly with a descriptive message.
4. Run `tacos-eval` for read-only derivation evaluation.
5. Run `tacos-build` for non-activating build validation.
6. Run `tacos-switch` only when activation is explicitly approved.
