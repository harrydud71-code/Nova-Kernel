#!/usr/bin/env bash
set -euo pipefail

# Samsung Galaxy A52s 5G (SM-A528B / a52sxq), EUR open defconfig.
# This script builds the kernel Image only. It does not package a flashable ZIP.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${OUT:-$ROOT/out}"
JOBS="${JOBS:-$(nproc)}"

export ARCH=arm64
export LLVM=1
export LLVM_IAS=1

# This legacy kernel expects unversioned LLVM tool names. Pin them consistently
# to LLVM 11 so compiler output and binutils agree on LTO/bitcode formats.
if [[ -x /usr/bin/clang-11 && -x /usr/bin/llvm-ar-11 ]]; then
  LLVM11_BIN="$(mktemp -d)"
  for tool in clang clang++ ld.lld llvm-ar llvm-nm llvm-objdump llvm-objcopy llvm-readelf llvm-strip; do
    case "$tool" in
      clang) target=/usr/bin/clang-11 ;;
      clang++) target=/usr/bin/clang++-11 ;;
      ld.lld) target=/usr/bin/ld.lld-11 ;;
      llvm-*) target="/usr/bin/${tool}-11" ;;
    esac
    if [[ -x "$target" ]]; then ln -sf "$target" "$LLVM11_BIN/$tool"; fi
  done
  export PATH="$LLVM11_BIN:$PATH"
fi

make -C "$ROOT" O="$OUT" vendor/a52sxq_eur_open_defconfig
make -C "$ROOT" O="$OUT" -j"$JOBS"
test -s "$OUT/arch/arm64/boot/Image"
file "$OUT/arch/arm64/boot/Image"
