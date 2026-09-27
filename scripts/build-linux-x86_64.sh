#!/usr/bin/env bash
# Reproducible native build and headless smoke test for Linux x86_64.
# Usage: ./scripts/build-linux-x86_64.sh
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_DIR="$ROOT/rust"
GODOT_DIR="$ROOT/godot"
LIB_DIR="$GODOT_DIR/addons/blink_core/bin/linux-x86_64"

if [[ "$(uname -m)" != "x86_64" ]]; then
  printf 'ERROR: This script targets Linux x86_64; detected %s\n' "$(uname -m)" >&2
  exit 2
fi

if ! command -v cargo >/dev/null 2>&1 && [[ -f "$HOME/.cargo/env" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
fi
for tool in cargo rustc clang ld.lld protoc godot; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'ERROR: Required build tool not found: %s\n' "$tool" >&2
    exit 2
  fi
done

printf '\n== Rust workspace tests ==\n'
(cd "$RUST_DIR" && CARGO_TERM_COLOR=never cargo test --workspace)

printf '\n== Build Linux GDExtension ==\n'
(cd "$RUST_DIR" && CARGO_TERM_COLOR=never cargo build -p blink-gdext)
mkdir -p "$LIB_DIR"
cp "$RUST_DIR/target/debug/libblink_gdext.so" "$LIB_DIR/libblink_gdext.so"
file "$LIB_DIR/libblink_gdext.so"

printf '\n== Validate asset references ==\n'
"$ROOT/scripts/asset-check.sh" "$ROOT"

check_godot_log() {
  local label="$1"
  shift
  local log
  log="$(mktemp)"
  if ! GODOT_SILENCE_ROOT_WARNING=1 "$@" 2>&1 | tee "$log"; then
    rm -f "$log"
    return 1
  fi
  if grep -E '^(SCRIPT ERROR:|ERROR:)' "$log"; then
    printf 'ERROR: Godot reported script/resource errors during %s.\n' "$label" >&2
    rm -f "$log"
    return 1
  fi
  rm -f "$log"
}

printf '\n== Godot headless editor import ==\n'
check_godot_log 'editor import' godot --headless --editor --path "$GODOT_DIR" --quit

printf '\nPASS: Linux x86_64 Rust tests, GDExtension build, asset validation and Godot editor import completed.\n'
printf 'Gameplay runtime is not certified by this script; see docs/DESKTOP_MIGRATION.md for the remaining runtime work.\n'
