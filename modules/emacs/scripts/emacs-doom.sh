#!/usr/bin/env bash
set -euo pipefail

DOOM_REPO="https://github.com/doomemacs/doomemacs"
INSTALL_ASTRO_LS=true   # astro-ls + typescript-language-server into ~/.local

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

# Run a command as the real user, with doom + ~/.local/bin on PATH
as_user() {
  local runner=()
  [ "$(id -u)" -eq 0 ] && runner=(sudo -u "$REAL_USER")
  "${runner[@]}" env \
    HOME="$REAL_HOME" \
    PATH="$DOOM_BIN:$REAL_HOME/.local/bin:$PATH" \
    "$@"
}

# ---------- steps ----------

clone_doom() {
  if [ -x "$DOOM_BIN/doom" ]; then
    log "Doom already cloned at $EMACS_DIR"
    return
  fi
  if [ -e "$EMACS_DIR" ]; then
    echo "$EMACS_DIR exists but is not Doom. Move it away first." >&2
    exit 1
  fi
  log "Cloning Doom into $EMACS_DIR"
  as_user git clone --depth 1 "$DOOM_REPO" "$EMACS_DIR"
}

install_or_sync_doom() {
  if [ -d "$EMACS_DIR/.local" ]; then
    log "Doom already installed, running doom sync"
    as_user doom sync
    return
  fi

  # Only let doom generate a starter config if you don't have one yet
  local config_flag="--config"
  if [ -d "$REAL_HOME/.config/doom" ] || [ -d "$REAL_HOME/.doom.d" ]; then
    config_flag="--no-config"
  fi

  log "Running doom install ($config_flag)"
  as_user doom install --force "$config_flag" --env --no-fonts
}

install_astro_ls() {
  [ "$INSTALL_ASTRO_LS" = true ] || return 0
  command -v npm &>/dev/null || { log "npm not found, skipping astro-ls"; return 0; }

  log "Installing astro-ls into $REAL_HOME/.local"
  as_user npm install -g --prefix "$REAL_HOME/.local" \
    @astrojs/language-server typescript typescript-language-server

  # Re-snapshot PATH so Emacs (and Eglot) can find astro-ls
  as_user doom env
}

# ---------- main ----------

echo "==> Provisioning Doom Emacs module..."

REAL_USER="$(resolve_real_user)"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
EMACS_DIR="$REAL_HOME/.config/emacs"
DOOM_BIN="$EMACS_DIR/bin"

log "User: $REAL_USER  Home: $REAL_HOME"

clone_doom
install_or_sync_doom
install_astro_ls

echo "==> Doom Emacs setup complete!"
echo "    Add $DOOM_BIN to your PATH to use the 'doom' command."
