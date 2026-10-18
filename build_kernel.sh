#!/usr/bin/env bash
set -euo pipefail

# Samsung Galaxy A52s 5G (SM-A528B / a52sxq), EUR open defconfig.
# This script builds the kernel Image only. It does not package a flashable ZIP.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${OUT:-$ROOT/out}"
JOBS="${JOBS:-$(nproc)}"

export ARCH=arm64
export LLVM=-11
export LLVM_IAS=1

make -C "$ROOT" O="$OUT" vendor/a52sxq_eur_open_defconfig
make -C "$ROOT" O="$OUT" -j"$JOBS"
test -s "$OUT/arch/arm64/boot/Image"
file "$OUT/arch/arm64/boot/Image"
