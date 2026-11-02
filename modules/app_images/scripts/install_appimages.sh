#!/usr/bin/env bash
set -e

BIN_DIR="$HOME/AppImages"
mkdir -p "$BIN_DIR"

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

  echo "Checking latest relese for $REPO ..."

  DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" |
    grep "browser_download_url" |
    grep -i 'linux-x86_64.AppImage"' |
    head -n 1 |
    cut -d '"' -f 4)

  if [ -z "$DOWNLOAD_URL" ]; then
    echo "Waning: Could not find a valid .AppImage release for $REPO. Skipping" >&2
    continue
  fi

  TARGET_PATH="$BIN_DIR/$APP_NAME.AppImage"

  echo "Downloading latest version of $APP_NAME ..."
  curl -L -o "$TARGET_PATH" "$DOWNLOAD_URL"
  chmod +x "$TARGET_PATH"
  echo "Successfully downloaded $APP_NAME to $TARGET_PATH"

  if command -v gearlever &>/dev/null; then
    echo "Integrating $APP_NAME with Gear Lever..."
    gearlever --integrate "$TARGET_PATH" || true
  fi
done
echo "All AppImages processed."
