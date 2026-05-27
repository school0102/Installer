#!/bin/bash

# ============================
# Configurações
# ============================

ZIP_URL="https://github.com"
EXT_PATH="$HOME/Google-Chrome-Extension"
TMP_ZIP="/tmp/extension.zip"

# Detecta Chrome/Chromium
CHROME_BIN=$(
    command -v google-chrome ||
    command -v chromium ||
    command -v chromium-browser
)

# ============================
# Verificações
# ============================

if [ -z "$CHROME_BIN" ]; then
    echo "❌ Chrome/Chromium não encontrado."
    exit 1
fi

for cmd in curl unzip; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ $cmd não encontrado."
        exit 1
    fi
done

# ============================
# Baixar extensão
# ============================

echo "📦 Baixando extensão..."

mkdir -p "$EXT_PATH"
rm -rf "$EXT_PATH"/*

curl -L "$ZIP_URL" -o "$TMP_ZIP"

if [ ! -f "$TMP_ZIP" ]; then
    echo "❌ Falha ao baixar ZIP."
    exit 1
fi

# ============================
# Extrair extensão
# ============================

echo "📂 Extraindo..."

unzip -q "$TMP_ZIP" -d "$EXT_PATH"

SUBDIR=$(find "$EXT_PATH" -mindepth 1 -maxdepth 1 -type d | head -n 1)

if [ -d "$SUBDIR" ]; then
    shopt -s dotglob
    mv "$SUBDIR"/* "$EXT_PATH"/ 2>/dev/null
    shopt -u dotglob
    rm -rf "$SUBDIR"
fi

rm -f "$TMP_ZIP"

# ============================
# Verifica manifest
# ============================

if [ ! -f "$EXT_PATH/manifest.json" ]; then
    echo "❌ manifest.json não encontrado."
    exit 1
fi

# ============================
# Descobre perfil padrão
# ============================

USER_DATA_DIR="$HOME/.config/google-chrome"

if [ ! -d "$USER_DATA_DIR" ]; then
    USER_DATA_DIR="$HOME/.config/chromium"
fi

# ============================
# Fecha Chrome
# ============================

echo "🛑 Fechando Chrome..."

pkill -f chrome 2>/dev/null || true
pkill -f chromium 2>/dev/null || true

sleep 3

# ============================
# Inicia com extensão (SINGLE LINE METHOD)
# ============================

echo "🚀 Iniciando Chrome em modo debug..."

"$CHROME_BIN" --user-data-dir="$USER_DATA_DIR" --load-extension="$EXT_PATH" --no-first-run
