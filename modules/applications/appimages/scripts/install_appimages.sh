#!/usr/bin/env bash
set -euo pipefail

# Resolve the real (non-root) user
REAL_USER="${SUDO_USER:-}"
[ -z "$REAL_USER" ] && REAL_USER="$(logname 2>/dev/null || true)"
if [ -z "$REAL_USER" ] || [ "$REAL_USER" = "root" ]; then
  REAL_USER="$(getent passwd | awk -F: '$3>=1000 && $3<65534 {print $1; exit}')"
fi
[ -z "$REAL_USER" ] && { echo "Could not determine the real user" >&2; exit 1; }

REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
REAL_UID="$(id -u "$REAL_USER")"
BIN_DIR="$REAL_HOME/AppImages"

echo "User: $REAL_USER  Home: $REAL_HOME  Target: $BIN_DIR"

# Run a command as the real user, with a session environment flatpak can use
as_user() {
  if [ "$(id -u)" -eq 0 ]; then
    sudo -u "$REAL_USER" env \
      HOME="$REAL_HOME" \
      XDG_RUNTIME_DIR="/run/user/$REAL_UID" \
      DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$REAL_UID/bus" \
      "$@"
  else
    "$@"
  fi
}

as_user mkdir -p "$BIN_DIR"

APPS=(
  "storytold/vectorcraft:vectorcraft"
  "storytold/photocraft:photocraft"
  "storytold/pdfcraft:pdfcraft"
  "storytold/effectcraft:effectcraft"
  "storytold/designcraft:designcraft"
)

gearlever_integrate() {
  local file="$1"
  if as_user flatpak info it.mijorus.gearlever &>/dev/null; then
    as_user flatpak run it.mijorus.gearlever --integrate --replace -y "$file" \
      || echo "Warning: Gear Lever integration failed for $file" >&2
  elif command -v gearlever &>/dev/null; then
    as_user gearlever --integrate --replace -y "$file" \
      || echo "Warning: Gear Lever integration failed for $file" >&2
  fi
}

for item in "${APPS[@]}"; do
  REPO="${item%%:*}"
  APP_NAME="${item##*:}"
  TARGET="$BIN_DIR/$APP_NAME.AppImage"

  if [ -f "$TARGET" ] || [ -f "$BIN_DIR/$APP_NAME.appimage" ]; then
    echo "Skipping $APP_NAME: already in $BIN_DIR"
    continue
  fi

  echo "Checking latest release for $REPO..."
  DOWNLOAD_URL=$(curl -fsS "https://api.github.com/repos/$REPO/releases/latest" \
    | grep "browser_download_url" \
    | grep -i 'linux-x86_64\.AppImage"' \
    | head -n 1 \
    | cut -d '"' -f 4 || true)

  if [ -z "$DOWNLOAD_URL" ]; then
    echo "Warning: no .AppImage release found for $REPO. Skipping." >&2
    continue
  fi

  echo "Downloading $APP_NAME..."
  TMP="$(mktemp)"
  if curl -fL -o "$TMP" "$DOWNLOAD_URL"; then
    mv "$TMP" "$TARGET"
    chown "$REAL_USER":"$(id -gn "$REAL_USER")" "$TARGET"
    chmod +x "$TARGET"
    gearlever_integrate "$TARGET"
  else
    rm -f "$TMP"
    echo "Warning: download failed for $APP_NAME" >&2
  fi
done

echo "All AppImages processed."
