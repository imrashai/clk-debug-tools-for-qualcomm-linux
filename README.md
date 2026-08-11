# clk-debug-tools-for-qualcomm-linux

This project hosts out-of-tree Linux kernel clk debug patches for linux-next, plus scripts that drive clock-measurement based debugging on Qualcomm SoCs. It exposes hardware clock-measure support via debugfs so the actual measured rate of a clock can be checked against rate configured.

## Branches

**main**: Primary development branch.

## Requirements

- A `linux-next` kernel checkout for your target, with the DebugCC clk
  debug patches from `patches/` applied and built/flashed to the target.
- `debugfs` mounted on the target (`/sys/kernel/debug`).
- Root shell access on the target device.
- A POSIX shell (`sh`) on-target to run the helper scripts in `scripts/`.
- `bash` and `git` on the host to run `apply_patches.sh`.

## Installation Instructions

1. Apply the common patch plus the patch series for your target to a
   matching `linux-next` checkout. Use the `apply_patches.sh` helper, which
   applies the common clk-debug core followed by the correct per-SoC series
   (in order), and automatically pulls in the shared SA8775P clock-controller
   patches that QCS8300 depends on.

   ```sh
   # from your linux-next checkout (the kernel git worktree)
   /path/to/clk-debug-tools-for-qualcomm-linux/apply_patches.sh <platform>
   ```

   Supported `<platform>` values: `sa8775p`, `qcs8300`, `qcs615`, `sc7280`.
   For example, for SA8775P:

   ```sh
   /path/to/clk-debug-tools-for-qualcomm-linux/apply_patches.sh sa8775p
   ```

   Useful options:

   ```sh
   # Dry-run: verify the series applies cleanly without committing
   apply_patches.sh -c sa8775p

   # Point at the kernel tree and/or patch location explicitly
   apply_patches.sh -C /path/to/linux-next -d /path/to/clk-debug-tools-for-qualcomm-linux qcs8300
   ```

   | Option | Meaning |
   |--------|---------|
   | `-C, --tree DIR` | kernel git worktree to apply into (default: current dir) |
   | `-d, --dir DIR`  | directory containing `common/` and `soc/*/` (default: script dir) |
   | `-c, --check`    | dry-run; verify patches apply, do not commit |
   | `-h, --help`     | show help |

   The script skips patches already present in the tree, and applies each
   patch with `git am` (falling back to `git apply` for plain diffs). If a
   `git am` fails, reset with `git am --abort` before retrying.

2. Build and flash the kernel to your target as usual.
3. Copy the scripts in `scripts/` onto the target.


## Usage

**Using a helper script (SA8775P example):**

```sh
sh scripts/clk_measure_sa8775p.sh <clock_name>
```

**Notes:**

- `<clock_name>` must be present in the script's internal clocks list.
- Output is the measured clock rate in Hz.


## License

This project is licensed on a per-folder basis:

- **`scripts/`** — BSD-3-Clause (see `LICENSE_BSD.txt`)
  ```
  Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
  SPDX-License-Identifier: BSD-3-Clause
  ```

- **`common/`, `soc/` (kernel patches)** — GPL-2.0-only (see `LICENSE_GPL2.0.txt`)
  ```
  Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
  SPDX-License-Identifier: GPL-2.0-only
  ```
