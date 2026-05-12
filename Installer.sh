#!/bin/bash

# =========================
# CONFIG
# =========================

ZIP_URL="https://github.com/school0102/Google-Chrome-Extension/archive/refs/heads/main.zip"

EXT_PATH="$HOME/Google-Chrome-Extension"
TMP_ZIP="/tmp/extension.zip"

# =========================
# DETECTA CHROME
# =========================

CHROME_BIN=$(
    command -v google-chrome ||
    command -v google-chrome-stable ||
    command -v chromium ||
    command -v chromium-browser
)

if [ -z "$CHROME_BIN" ]; then
    echo "❌ Chrome/Chromium não encontrado"
    exit 1
fi

# =========================
# DEPENDÊNCIAS
# =========================

for cmd in curl unzip; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ Dependência faltando: $cmd"
        exit 1
    fi
done

# =========================
# BAIXA EXTENSÃO
# =========================

echo "📦 Baixando extensão..."

mkdir -p "$EXT_PATH"
rm -rf "$EXT_PATH"/*

curl -L "$ZIP_URL" -o "$TMP_ZIP"

if [ ! -f "$TMP_ZIP" ]; then
    echo "❌ Falha ao baixar ZIP"
    exit 1
fi

# =========================
# EXTRAI
# =========================

echo "📂 Extraindo..."

unzip -q "$TMP_ZIP" -d "$EXT_PATH"

SUBDIR=$(find "$EXT_PATH" -mindepth 1 -maxdepth 1 -type d | head -n 1)

if [ -d "$SUBDIR" ]; then
    shopt -s dotglob
    mv "$SUBDIR"/* "$EXT_PATH"/
    shopt -u dotglob
    rm -rf "$SUBDIR"
fi

rm -f "$TMP_ZIP"

# =========================
# VERIFICA MANIFEST
# =========================

if [ ! -f "$EXT_PATH/manifest.json" ]; then
    echo "❌ manifest.json não encontrado"
    exit 1
fi

# =========================
# PERFIL REAL
# =========================

if [ -d "$HOME/.config/google-chrome" ]; then
    USER_DATA="$HOME/.config/google-chrome"
elif [ -d "$HOME/.config/chromium" ]; then
    USER_DATA="$HOME/.config/chromium"
else
    echo "❌ Perfil do Chrome não encontrado"
    exit 1
fi

# =========================
# FECHA CHROME
# =========================

echo "🛑 Fechando Chrome..."

pkill -f chrome 2>/dev/null || true
pkill -f chromium 2>/dev/null || true

sleep 4

# =========================
# ABRE COM EXTENSÃO
# =========================

echo "🚀 Abrindo Chrome..."

"$CHROME_BIN" \
    --user-data-dir="$USER_DATA" \
    --disable-extensions-file-access-check \
    --disable-extensions-except="$EXT_PATH" \
    --load-extension="$EXT_PATH" \
    --restore-last-session \
    --enable-unsafe-extension-debugging \
    --no-first-run \
    >/dev/null 2>&1 &

sleep 5

# =========================
# VERIFICA
# =========================

if pgrep -f "$CHROME_BIN" >/dev/null; then
    echo "✅ Chrome iniciado"
    echo "✅ Extensão carregada em:"
    echo "   $EXT_PATH"
else
    echo "❌ Falha ao iniciar Chrome"
fi
