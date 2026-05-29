#!/bin/bash

# Repo info
REPO_USER="school0102"
REPO_NAME="Google-Chrome-Extension"

# Paths
BASE_DIR="$HOME/.local/share/chrome-extension-loader"
ZIP_FILE="$BASE_DIR/extension.zip"

# GitHub ZIP URL
ZIP_URL="https://github.com/$REPO_USER/$REPO_NAME/archive/refs/heads/main.zip"

# Create folder
mkdir -p "$BASE_DIR"

echo "[+] Downloading extension..."
curl -L "$ZIP_URL" -o "$ZIP_FILE"

echo "[+] Extracting..."
unzip -o "$ZIP_FILE" -d "$BASE_DIR" >/dev/null

EXT_PATH="$BASE_DIR/$REPO_NAME-main"

echo "[+] Launching Chrome with extension..."

# Try common Chrome executable names
if command -v google-chrome >/dev/null 2>&1; then
    CHROME_BIN="google-chrome"
elif command -v chromium >/dev/null 2>&1; then
    CHROME_BIN="chromium"
elif command -v chromium-browser >/dev/null 2>&1; then
    CHROME_BIN="chromium-browser"
else
    echo "[-] Chrome/Chromium not found."
    exit 1
fi

"$CHROME_BIN" \
  --disable-extensions-except="$EXT_PATH" \
  --load-extension="$EXT_PATH"
