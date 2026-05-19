#!/usr/bin/env bash

set -Eeuo pipefail

# =========================================================
# CONFIG
# =========================================================

ZIP_URL="https://github.com/school0102/Google-Chrome-Extension/archive/refs/heads/main.zip"

BASE_DIR="$HOME/.local/share/custom-extension-loader"
EXT_DIR="$BASE_DIR/extension"
PROFILE_DIR="$BASE_DIR/chrome-profile"

TMP_ZIP="$(mktemp /tmp/chrome-ext-XXXX.zip)"
TMP_DIR="$(mktemp -d)"

# =========================================================
# CLEANUP
# =========================================================

cleanup() {
    rm -f "$TMP_ZIP"
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

# =========================================================
# DETECTA CHROME/CHROMIUM
# =========================================================

CHROME_BIN=$(
    command -v google-chrome ||
    command -v google-chrome-stable ||
    command -v chromium ||
    command -v chromium-browser
)

if [[ -z "${CHROME_BIN:-}" ]]; then
    echo "❌ Google Chrome/Chromium não encontrado"
    exit 1
fi

echo "✅ Navegador encontrado:"
echo "   $CHROME_BIN"
echo

# =========================================================
# DEPENDÊNCIAS
# =========================================================

for cmd in curl unzip find mktemp; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ Dependência faltando: $cmd"
        exit 1
    fi
done

# =========================================================
# PREPARA PASTAS
# =========================================================

mkdir -p "$BASE_DIR"

rm -rf "$EXT_DIR"
mkdir -p "$EXT_DIR"

mkdir -p "$PROFILE_DIR"

# =========================================================
# BAIXA EXTENSÃO
# =========================================================

echo "📦 Baixando extensão..."
echo

curl -fsSL "$ZIP_URL" -o "$TMP_ZIP"

if [[ ! -s "$TMP_ZIP" ]]; then
    echo "❌ Falha ao baixar ZIP"
    exit 1
fi

echo "✅ Download concluído"
echo

# =========================================================
# EXTRAI
# =========================================================

echo "📂 Extraindo extensão..."
echo

unzip -q "$TMP_ZIP" -d "$TMP_DIR"

SUBDIR="$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)"

if [[ -z "${SUBDIR:-}" ]]; then
    echo "❌ Estrutura do ZIP inválida"
    exit 1
fi

shopt -s dotglob

mv "$SUBDIR"/* "$EXT_DIR"/

shopt -u dotglob

# =========================================================
# VERIFICA MANIFEST
# =========================================================

MANIFEST="$EXT_DIR/manifest.json"

if [[ ! -f "$MANIFEST" ]]; then
    echo "❌ manifest.json não encontrado"
    echo
    echo "Conteúdo encontrado:"
    ls -la "$EXT_DIR"
    exit 1
fi

echo "✅ manifest.json encontrado"
echo

# =========================================================
# DETECTA MANIFEST VERSION
# =========================================================

MANIFEST_VERSION=$(
    grep -o '"manifest_version"[[:space:]]*:[[:space:]]*[0-9]*' "$MANIFEST" \
    | grep -o '[0-9]*' \
    | head -n 1
)

if [[ -z "${MANIFEST_VERSION:-}" ]]; then
    echo "⚠️ Não foi possível detectar manifest_version"
else
    echo "✅ Manifest V$MANIFEST_VERSION detectado"
fi

echo

# =========================================================
# MOSTRA ARQUIVOS
# =========================================================

echo "📁 Arquivos da extensão:"
echo

ls -la "$EXT_DIR"

echo

# =========================================================
# FECHA CHROME ANTIGO
# =========================================================

echo "🛑 Fechando instâncias antigas..."
echo

pkill -f chrome 2>/dev/null || true
pkill -f chromium 2>/dev/null || true

sleep 3

# =========================================================
# INICIA CHROME
# =========================================================

echo "🚀 Abrindo Chrome..."
echo

"$CHROME_BIN" \
    --user-data-dir="$PROFILE_DIR" \
    --load-extension="$EXT_DIR" \
    --disable-extensions-except="$EXT_DIR" \
    --no-first-run \
    --no-default-browser-check \
    --enable-logging=stderr \
    --v=1 \
    &

sleep 5

# =========================================================
# VERIFICA PROCESSO
# =========================================================

if pgrep -f "$PROFILE_DIR" >/dev/null; then
    echo
    echo "✅ Chrome iniciado com sucesso"
    echo
    echo "📦 Extensão carregada em:"
    echo "   $EXT_DIR"
    echo
    echo "👤 Perfil isolado:"
    echo "   $PROFILE_DIR"
    echo
    echo "🌐 Abra:"
    echo "   chrome://extensions"
    echo
    echo "🧩 Ative:"
    echo "   Modo do desenvolvedor"
    echo
else
    echo "❌ Falha ao iniciar Chrome"
    exit 1
fi
