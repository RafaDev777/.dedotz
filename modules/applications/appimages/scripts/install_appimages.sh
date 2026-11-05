#!/usr/bin/env bash
set -e
echo "get the user name"
REAL_USER="$(logname)"
echo "the user is $REAL_USER"
BIN_DIR="/home/$REAL_USER/AppImages"
echo "checking and creating AppImages folder"
mkdir -p "$BIN_DIR"
echo "installing app image in $BIN_DIR"

APPS=(
  "storytold/vectorcraft:vectorcraft"
  "storytold/photocraft:photocraft"
  "storytold/pdfcraft:pdfcraft"
  "storytold/effectcraft:effectcraft"
  "storytold/designcraft:designcraft"
)

for item in "${APPS[@]}"; do
  REPO="${item%%:*}"
  APP_NAME="${item##*:}"

  # Check if the AppImage already exists locally (checking both uppercase and lowercase extensions)
  if [ -f "$BIN_DIR/$APP_NAME.AppImage" ] || [ -f "$BIN_DIR/$APP_NAME.appimage" ]; then
      echo "Skipping $APP_NAME: AppImage already exists in $BIN_DIR."
      continue
  fi

  echo "Checking latest release for $REPO..."

  DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" |
    grep "browser_download_url" |
    grep -i 'linux-x86_64\.AppImage"' |
    head -n 1 |
    cut -d '"' -f 4)

  if [ -z "$DOWNLOAD_URL" ]; then
    echo "Warning: Could not find a valid .AppImage release for $REPO. Skipping." >&2
    continue
  fi

  TARGET_PATH="$BIN_DIR/$APP_NAME.AppImage"

  echo "Downloading latest version of $APP_NAME..."
  curl -L -o "$TARGET_PATH" "$DOWNLOAD_URL"
  chmod +x "$TARGET_PATH"
  echo "Successfully downloaded $APP_NAME to $TARGET_PATH"

  # Integrate with Gear Lever if available
  if flatpak info it.mijorus.gearlever &>/dev/null; then
    echo "Integrating $APP_NAME with Gear Lever..."
    flatpak run it.mijorus.gearlever "$TARGET_PATH" || true
  elif command -v gearlever &>/dev/null; then
    echo "Integrating $APP_NAME with Gear Lever..."
    gearlever "$TARGET_PATH" || true
  fi
done

echo "All AppImages processed."
