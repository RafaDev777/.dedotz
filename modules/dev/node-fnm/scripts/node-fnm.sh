#!/usr/bin/env bash
set -euo pipefail

NODE_VERSION="lts-latest"   # or pin e.g. "24"

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
  "${runner[@]}" env HOME="$REAL_HOME" COREPACK_ENABLE_DOWNLOAD_PROMPT=0 "$@"
}

# Run a snippet in a bash that has fnm's environment loaded
in_fnm() {
  as_user bash -c 'eval "$(fnm env --shell bash)"; '"$1"
}

install_node() {
  log "Installing Node ($NODE_VERSION)"
  in_fnm "fnm install $NODE_VERSION"
  in_fnm "fnm default $NODE_VERSION"
}

enable_pnpm() {
  # Node 25+ no longer bundles corepack, so install it into the fnm Node first
  if ! in_fnm "command -v corepack" &>/dev/null; then
    log "corepack not bundled with this Node, installing via npm"
    in_fnm "npm install -g corepack"
  fi

  log "Enabling pnpm through corepack"
  in_fnm "corepack enable pnpm && corepack prepare pnpm@latest --activate"
}

# ---------- main ----------

echo "==> Provisioning Node (fnm + pnpm) module..."

REAL_USER="$(resolve_real_user)"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
log "User: $REAL_USER  Home: $REAL_HOME"

command -v fnm &>/dev/null || { echo "fnm not installed" >&2; exit 1; }

install_node
enable_pnpm

log "node $(in_fnm 'node -v'), pnpm $(in_fnm 'pnpm -v')"
echo "==> Node setup complete!"
