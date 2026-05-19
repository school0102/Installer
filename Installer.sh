#!/usr/bin/env bash

set -Eeuo pipefail

# =========================
# CONFIG
# =========================

ZIP_URL="https://github.com/school0102/Google-Chrome-Extension/archive/refs/heads/main.zip"

EXT_PATH="$HOME/.local/share/google-chrome-extension"
TMP_DIR="$(mktemp -d)"
TMP_ZIP="$TMP_DIR/extension.zip"

# Perfil isolado (MUITO mais seguro)
PROFILE_DIR="$HOME/.config/chrome-extension-profile"

# =========================
# CLEANUP
# =========================

cleanup() {
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

# =========================
# DETECTA CHROME
# =========================

CHROME_BIN=""

for bin in \
    google-chrome \
    google-chrome-stable \
    chromium \
    chromium-browser
do
    if command -v "$bin" >/dev/null 2>&1; then
        CHROME_BIN="$(command -v "$bin")"
        break
    fi
done

if [[ -z "$CHROME_BIN" ]]; then
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

rm -rf "$EXT_PATH"
mkdir -p "$EXT_PATH"

curl \
    --fail \
    --location \
    --silent \
    --show-error \
    "$ZIP_URL" \
    -o "$TMP_ZIP"

if [[ ! -s "$TMP_ZIP" ]]; then
    echo "❌ Download falhou"
    exit 1
fi

# =========================
# EXTRAI
# =========================

echo "📂 Extraindo..."

unzip -q "$TMP_ZIP" -d "$TMP_DIR/unpacked"

SUBDIR="$(find "$TMP_DIR/unpacked" -mindepth 1 -maxdepth 1 -type d | head -n 1)"

if [[ -z "$SUBDIR" || ! -d "$SUBDIR" ]]; then
    echo "❌ Estrutura ZIP inválida"
    exit 1
fi

cp -R "$SUBDIR"/. "$EXT_PATH"/

# =========================
# VERIFICA MANIFEST
# =========================

if [[ ! -f "$EXT_PATH/manifest.json" ]]; then
    echo "❌ manifest.json não encontrado"
    exit 1
fi

echo "✅ Extensão válida"

# =========================
# ABRE CHROME
# =========================

echo "🚀 Abrindo Chrome..."

mkdir -p "$PROFILE_DIR"

"$CHROME_BIN" \
    --user-data-dir="$PROFILE_DIR" \
    --disable-extensions-except="$EXT_PATH" \
    --load-extension="$EXT_PATH" \
    --no-first-run \
    >/dev/null 2>&1 &

sleep 5

# =========================
# VERIFICA
# =========================

if pgrep -f "$PROFILE_DIR" >/dev/null; then
    echo "✅ Chrome iniciado"
    echo "✅ Extensão carregada:"
    echo "   $EXT_PATH"
else
    echo "❌ Falha ao iniciar Chrome"
    exit 1
fi
