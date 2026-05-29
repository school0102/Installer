#!/bin/bash

# ==========================================
# Stable Chrome Extension Loader
# ==========================================

set -e

# ==========================================
# CONFIGURATION
# ==========================================

# IMPORTANT:
# Replace this with the REAL GitHub repo ZIP URL
#
# Examples:
# https://github.com/USER/REPO/archive/refs/heads/main.zip
# https://github.com/USER/REPO/archive/refs/heads/master.zip
#
ZIP_URL="https://github.com/USER/REPO/archive/refs/heads/main.zip"

EXT_PATH="$HOME/Google-Chrome-Extension"
TMP_ZIP="$HOME/extension_download.zip"
USER_DATA_DIR="$HOME/Chrome-Dev-Profile"

# ==========================================
# DETECT CHROME / CHROMIUM
# ==========================================

CHROME_BIN=$(
    command -v google-chrome ||
    command -v chromium ||
    command -v chromium-browser
)

# ==========================================
# CHECK DEPENDENCIES
# ==========================================

if [ -z "$CHROME_BIN" ]; then
    echo "❌ Chrome/Chromium not found."
    exit 1
fi

for cmd in curl unzip find; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ Missing dependency: $cmd"
        exit 1
    fi
done

# ==========================================
# PREPARE FOLDERS
# ==========================================

echo "🧹 Cleaning previous files..."

mkdir -p "$EXT_PATH"

rm -rf "$EXT_PATH"/*
rm -f "$TMP_ZIP"

# ==========================================
# DOWNLOAD EXTENSION ZIP
# ==========================================

echo "📦 Downloading extension..."

curl -L --fail --silent --show-error \
    "$ZIP_URL" \
    -o "$TMP_ZIP"

# ==========================================
# VERIFY ZIP
# ==========================================

if [ ! -f "$TMP_ZIP" ]; then
    echo "❌ ZIP file was not downloaded."
    exit 1
fi

if [ ! -s "$TMP_ZIP" ]; then
    echo "❌ Downloaded ZIP is empty."
    exit 1
fi

# Validate ZIP integrity
if ! unzip -tq "$TMP_ZIP" >/dev/null 2>&1; then
    echo "❌ Downloaded file is NOT a valid ZIP archive."
    exit 1
fi

echo "✅ ZIP downloaded successfully."

# ==========================================
# EXTRACT EXTENSION
# ==========================================

echo "📂 Extracting extension..."

unzip -q "$TMP_ZIP" -d "$EXT_PATH"

# ==========================================
# HANDLE GITHUB ROOT FOLDER
# ==========================================

ROOT_DIR=$(find "$EXT_PATH" -mindepth 1 -maxdepth 1 -type d | head -n 1)

if [ -n "$ROOT_DIR" ]; then
    echo "📁 Moving extension files..."

    shopt -s dotglob

    mv "$ROOT_DIR"/* "$EXT_PATH"/ 2>/dev/null || true

    shopt -u dotglob

    rm -rf "$ROOT_DIR"
fi

# Remove temporary ZIP
rm -f "$TMP_ZIP"

# ==========================================
# FIND manifest.json
# ==========================================

MANIFEST=$(find "$EXT_PATH" -type f -name "manifest.json" | head -n 1)

if [ -z "$MANIFEST" ]; then
    echo "❌ manifest.json not found."
    echo ""
    echo "Extracted files:"
    find "$EXT_PATH" | head -30
    exit 1
fi

# If manifest is inside a subfolder,
# use that folder as extension root
REAL_EXT_PATH=$(dirname "$MANIFEST")

echo "✅ manifest.json found:"
echo "   $MANIFEST"

# ==========================================
# CLOSE OLD CHROME INSTANCES
# ==========================================

echo "🛑 Closing old Chrome processes..."

pkill -9 -f chrome 2>/dev/null || true
pkill -9 -f chromium 2>/dev/null || true

sleep 2

# ==========================================
# START CHROME WITH EXTENSION
# ==========================================

echo ""
echo "🚀 Launching Chrome..."
echo "📂 Extension path: $REAL_EXT_PATH"
echo ""
echo "⚠️ DO NOT CLOSE THIS TERMINAL"
echo ""

"$CHROME_BIN" \
    --user-data-dir="$USER_DATA_DIR" \
    --load-extension="$REAL_EXT_PATH" \
    --no-first-run

echo ""
echo "ℹ️ Chrome closed."
read -p "Press ENTER to exit..."
