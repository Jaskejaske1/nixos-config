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
Before running any evaluation or system generation step, Codex must systematically perform this verification sequence:
1. Format all code targets via `nixfmt`.
2. Stage and check trees with `git add .`.
3. Auto-commit changes locally with a descriptive commit message before building.
