#!/usr/bin/env bash
#
# apply_patches.sh - apply the clock-measure (debug mux) patch series for a
# given Qualcomm platform.
#
# The series is split across the common core and per-SoC trees, found under
# the patch location (see -d/--dir below, defaults to the directory holding
# this script):
#   common/        - clk-debug clock-measure core (prerequisite for all)
#   soc/sa8775p/   - SA8775P bindings, shared clock controllers, dts
#   soc/qcs8300/   - QCS8300 gcc bindings, gcc driver, dts
#   soc/qcs615/    - QCS615 gcc bindings, gcc driver (standalone)
#   soc/sc7280/    - SC7280 bindings, clock controllers, dts (standalone)
#
# QCS8300 reuses the SA8775P shared clock-controller drivers (camcc / dispcc /
# gpucc / videocc / gcc-sa8775p), so the QCS8300 build also needs the SA8775P
# clock-controller patch:
#   0002-clk-qcom-sa8775p-Add-debug-mux-for-clock-controllers.patch
# and the SA8775P bindings patch that defines the *_DEBUG_MUX IDs it consumes.
#
# QCS615 and SC7280 are standalone: each has its own bindings and clock
# controller debug muxes and does not reuse any SA8775P shared clock controller.
#
# Patches are applied to the kernel git tree at the current working directory
# (override with -C/--tree); the patch files are read from the patch location.
#
# Usage:
#   ./apply_patches.sh sa8775p                 # common + full SA8775P series
#   ./apply_patches.sh qcs8300                 # common + QCS8300 series + shared SA8775P CC patch
#   ./apply_patches.sh qcs615                  # common + standalone QCS615 series
#   ./apply_patches.sh sc7280                  # common + standalone SC7280 series
#   ./apply_patches.sh -d /path/to/patches sa8775p
#   ./apply_patches.sh -C /path/to/kernel -d /path/to/patches qcs8300
#
# Options:
#   -d, --dir DIR   directory containing common/ and soc/{sa8775p,qcs8300,
#                   qcs615,sc7280}/
#                   (default: the directory containing this script)
#   -C, --tree DIR  kernel git worktree to apply into (default: current dir)
#   -c, --check     dry-run: verify the patches apply, do not commit
#   -h, --help      show this help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Where the patch trees live; overridable with -d/--dir.
PATCH_ROOT="$SCRIPT_DIR"
# Kernel git worktree to apply into; overridable with -C/--tree.
KERNEL_DIR="$PWD"

COMMON_SUBDIR="common"
SA8775P_SUBDIR="soc/sa8775p"
QCS8300_SUBDIR="soc/qcs8300"
QCS615_SUBDIR="soc/qcs615"
SC7280_SUBDIR="soc/sc7280"

# SA8775P patches the QCS8300 build depends on (shared clock controllers +
# the bindings that define the clock IDs those controllers reference).
SA8775P_SHARED_BINDINGS="0001-dt-bindings-clock-qcom-Add-debug-mux-support-on-SA87.patch"
SA8775P_SHARED_CC="0002-clk-qcom-sa8775p-Add-debug-mux-for-clock-controllers.patch"

CHECK_ONLY=0

usage() {
	sed -n '2,/^set -euo/p' "$0" | sed '$d; s/^#\{0,1\} \{0,1\}//'
	exit "${1:-0}"
}

die() {
	echo "error: $*" >&2
	exit 1
}

# already_applied <patch-file>
# True if the patch's diff is already present in the tree, i.e. it reverses
# cleanly. Works for both mailbox (git am) and plain diff patches since
# git apply reads only the diff hunks and ignores the mail headers.
already_applied() {
	git apply --reverse --check "$1" >/dev/null 2>&1
}

# apply_one <patch-file>
# git am if the file is a full mailbox patch (starts with "From <sha>"),
# else fall back to git apply.
apply_one() {
	local patch="$1"
	[ -f "$patch" ] || die "patch not found: $patch"

	if already_applied "$patch"; then
		echo "  [skip]  $patch (already applied)"
		return
	fi

	if [ "$CHECK_ONLY" -eq 1 ]; then
		echo "  [check] $patch"
		git apply --check --verbose "$patch" 2>/dev/null \
			|| die "patch does not apply cleanly: $patch"
		return
	fi

	echo "  [apply] $patch"
	if head -1 "$patch" | grep -q '^From [0-9a-f]\{7,\}'; then
		git am --keep-cr "$patch" \
			|| die "git am failed for $patch (run 'git am --abort' to reset)"
	else
		git apply "$patch" && git add -A \
			&& git commit -q -m "$(basename "$patch" .patch)" \
			|| die "git apply failed for $patch"
	fi
}

# apply_dir <dir>  - apply every NNNN-*.patch in sorted order
apply_dir() {
	local dir="$1"
	[ -d "$dir" ] || die "patch directory not found: $dir"
	local p
	for p in "$dir"/[0-9]*.patch; do
		[ -e "$p" ] || die "no patches found in $dir"
		apply_one "$p"
	done
}

main() {
	local platform=""
	while [ $# -gt 0 ]; do
		case "$1" in
			-d|--dir)   shift; [ $# -gt 0 ] || die "-d/--dir needs an argument"; PATCH_ROOT="$1" ;;
			-C|--tree)  shift; [ $# -gt 0 ] || die "-C/--tree needs an argument"; KERNEL_DIR="$1" ;;
			-c|--check) CHECK_ONLY=1 ;;
			-h|--help)  usage 0 ;;
			sa8775p|qcs8300|qcs615|sc7280) platform="$1" ;;
			*) die "unknown argument: $1 (expected sa8775p, qcs8300, qcs615 or sc7280)" ;;
		esac
		shift
	done

	[ -n "$platform" ] || { echo "error: no platform given" >&2; usage 1; }

	# Resolve the patch location and the three trees under it.
	[ -d "$PATCH_ROOT" ] || die "patch location not found: $PATCH_ROOT"
	PATCH_ROOT="$(cd "$PATCH_ROOT" && pwd)"
	local common_dir="$PATCH_ROOT/$COMMON_SUBDIR"
	local sa8775p_dir="$PATCH_ROOT/$SA8775P_SUBDIR"
	local qcs8300_dir="$PATCH_ROOT/$QCS8300_SUBDIR"
	local qcs615_dir="$PATCH_ROOT/$QCS615_SUBDIR"
	local sc7280_dir="$PATCH_ROOT/$SC7280_SUBDIR"

	# Move into the kernel tree; all git operations run here.
	[ -d "$KERNEL_DIR" ] || die "kernel tree not found: $KERNEL_DIR"
	cd "$KERNEL_DIR"
	git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
		|| die "not a git worktree: $KERNEL_DIR (use -C to point at the kernel tree)"

	echo "==> Patch location: $PATCH_ROOT"
	echo "==> Kernel tree:    $KERNEL_DIR"

	# The clk-debug core is a prerequisite for every platform.
	echo "==> Applying common clk-debug core"
	apply_dir "$common_dir"

	case "$platform" in
	sa8775p)
		echo "==> Applying SA8775P series"
		apply_dir "$sa8775p_dir"
		;;
	qcs8300)
		# QCS8300 reuses the SA8775P shared clock controllers, so pull in
		# the SA8775P bindings + clock-controller patch before the
		# QCS8300-specific series.
		echo "==> Applying shared SA8775P clock-controller patches for QCS8300"
		apply_one "$sa8775p_dir/$SA8775P_SHARED_BINDINGS"
		apply_one "$sa8775p_dir/$SA8775P_SHARED_CC"

		echo "==> Applying QCS8300 series"
		apply_dir "$qcs8300_dir"
		;;
	qcs615)
		# QCS615 is standalone (own gcc bindings + gcc driver); no shared
		# SA8775P clock-controller patches are needed.
		echo "==> Applying QCS615 series"
		apply_dir "$qcs615_dir"
		;;
	sc7280)
		# SC7280 is standalone (own bindings + clock controllers); no shared
		# SA8775P clock-controller patches are needed.
		echo "==> Applying SC7280 series"
		apply_dir "$sc7280_dir"
		;;
	esac

	if [ "$CHECK_ONLY" -eq 1 ]; then
		echo "==> All patches for '$platform' apply cleanly (dry-run)"
	else
		echo "==> Done applying patches for '$platform'"
	fi
}

main "$@"
