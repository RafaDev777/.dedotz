#!/usr/bin/env bash
set -euo pipefail

TOOLCHAIN="stable"
COMPONENTS=(rust-analyzer rust-src clippy rustfmt)

log() { echo " -> $*"; }

resolve_real_user() {
  local user="${SUDO_USER:-}"
  [ -z "$user" ] && user="$(logname 2>/dev/null || true)"
  if [ -z "$user" ] || [ "$user" = "root" ]; then
    user="$(getent passwd | awk -F: '$3>=1000 && $3<65534 {print $1; exit}')"
  fi
  [ -n "$user" ] || { echo "Could not determine the real user" >&2; exit 1; }
  echo "$user"
}

as_user() {
  local runner=()
  [ "$(id -u)" -eq 0 ] && runner=(sudo -u "$REAL_USER")
  "${runner[@]}" env HOME="$REAL_HOME" "$@"
}

echo "==> Provisioning Rust toolchain..."

REAL_USER="$(resolve_real_user)"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
log "User: $REAL_USER  Home: $REAL_HOME"

command -v rustup &>/dev/null || { echo "rustup not installed" >&2; exit 1; }

log "Installing $TOOLCHAIN toolchain and setting it as default"
as_user rustup default "$TOOLCHAIN"

log "Adding components: ${COMPONENTS[*]}"
as_user rustup component add "${COMPONENTS[@]}"

echo "==> Rust toolchain ready!"
