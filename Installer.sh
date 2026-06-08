#!/bin/bash

REPO_USER="school0102"
REPO_NAME="Google-Chrome-Extension"

BASE_DIR="$HOME/.local/share/chrome-extension-loader"
ZIP_FILE="$BASE_DIR/ext.zip"

ZIP_URL="https://github.com/$REPO_USER/$REPO_NAME/archive/refs/heads/main.zip"

mkdir -p "$BASE_DIR"

echo "[+] Downloading..."
curl -L "$ZIP_URL" -o "$ZIP_FILE"

echo "[+] Extracting..."
unzip -o "$ZIP_FILE" -d "$BASE_DIR" >/dev/null

EXT_PATH="$BASE_DIR/$REPO_NAME-main"

# Find Chrome
if command -v google-chrome >/dev/null 2>&1; then
    CHROME="google-chrome"
elif command -v chromium >/dev/null 2>&1; then
    CHROME="chromium"
elif command -v chromium-browser >/dev/null 2>&1; then
    CHROME="chromium-browser"
else
    echo "Chrome not found"
    exit 1
fi

echo "[+] Launching Chrome..."

"$CHROME" \
  --enable-logging --v=1 \
  --load-extension="$EXT_PATH"
