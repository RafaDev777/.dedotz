#!/usr/bin/env bash
set -euo pipefail

# ---------- helpers ----------

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

# Run a command as the real user (no-op wrapper if already that user)
as_user() {
  if [ "$(id -u)" -eq 0 ]; then
    sudo -u "$REAL_USER" env HOME="$REAL_HOME" "$@"
  else
    "$@"
  fi
}

# ---------- steps ----------

create_org_dir() {
  log "Ensuring $ORG_DIR exists"
  as_user mkdir -p "$ORG_DIR"
}

deploy_stignore() {
  local file="$ORG_DIR/.stignore"
  if [ -f "$file" ]; then
    log "$file already exists, skipping"
    return
  fi

  as_user tee "$file" >/dev/null <<'EOF'
// Ignore Emacs auto-save and lock files
.#*
#*#
*~
EOF
  log "Created $file"
}

enable_syncthing() {
  command -v systemctl &>/dev/null || { log "systemctl not found, skipping"; return; }

  log "Enabling Syncthing user service for $REAL_USER"
  if as_user env XDG_RUNTIME_DIR="/run/user/$REAL_UID" \
       systemctl --user enable --now syncthing.service; then
    return
  fi

  # No active session for the user (e.g. fresh install): enable for next login
  log "No user session available, enabling for next login instead"
  systemctl --global enable syncthing.service
}

# ---------- main ----------

echo "==> Provisioning Syncthing module..."

REAL_USER="$(resolve_real_user)"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
REAL_UID="$(id -u "$REAL_USER")"
ORG_DIR="$REAL_HOME/org"

log "User: $REAL_USER  Home: $REAL_HOME"

create_org_dir
deploy_stignore
enable_syncthing

echo "==> Syncthing setup complete!"
