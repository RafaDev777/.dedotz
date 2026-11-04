#!/bin/bash
set -euo pipefail

echo "==> Provisioning Syncthing module..."

echo "Get user home dir"
USER_HOME_DIR="/home/$(logname)"
# 1. Ensure required local directories exist
mkdir -p "$USER_HOME_DIR/org"

# 2. Deploy Emacs ignore file for Org-mode if it doesn't exist
STIGNORE="$USER_HOME_DIR/org/.stignore"
if [ ! -f "$STIGNORE" ]; then
    cat << 'EOF' > "$STIGNORE"
// Ignore Emacs auto-save and lock files
.#*
#*#
*~
EOF
    echo " -> Created $STIGNORE"
fi

# 3. Enable and start Syncthing user service safely
if command -v systemctl &>/dev/null; then
    echo " -> Enabling and starting Syncthing user service..."

    # If the script is invoked via sudo, target the real calling user
    if [ "$EUID" -eq 0 ] && [ -n "${SUDO_USER:-}" ]; then
        sudo -u "$SUDO_USER" XDG_RUNTIME_DIR="/run/user/$(id -u "$SUDO_USER")" systemctl --user enable --now syncthing.service
    else
        systemctl --user enable --now syncthing.service
    fi
fi

echo "==> Syncthing setup complete!"
