#!/bin/bash

REPO="https://github.com/school0102/Google-Chrome-Extension.git"
EXT_DIR="$HOME/.local/share/Google-Chrome-Extension"

if [ ! -d "$EXT_DIR" ]; then
    git clone "$REPO" "$EXT_DIR"
else
    cd "$EXT_DIR" && git pull
fi

google-chrome \
  --disable-extensions-except="$EXT_DIR" \
  --load-extension="$EXT_DIR"
