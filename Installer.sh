#!/bin/bash

# ============================
# Configurações
# ============================

ZIP_URL="https://github.com/school0102/Google-Chrome-Extension/archive/refs/heads/main.zip"
EXT_PATH="$HOME/Google-Chrome-Extension"
TMP_ZIP="/tmp/extension.zip"

# Detecta Chrome ou Chromium
CHROME_BIN=$(command -v google-chrome || command -v chromium || command -v chromium-browser)

# ============================
# Verificações
# ============================

if [ -z "$CHROME_BIN" ]; then
    echo "❌ Google Chrome ou Chromium não encontrado."
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "❌ curl não encontrado."
    exit 1
fi

if ! command -v unzip &> /dev/null; then
    echo "❌ unzip não encontrado."
    exit 1
fi

# ============================
# Baixa extensão
# ============================

echo "🚀 Instalando/atualizando extensão..."

# Cria pasta da extensão
mkdir -p "$EXT_PATH"

# Remove conteúdo antigo
rm -rf "$EXT_PATH"/*

# Baixa ZIP
echo "📦 Baixando arquivos..."
curl -L "$ZIP_URL" -o "$TMP_ZIP"

# Verifica download
if [ ! -f "$TMP_ZIP" ]; then
    echo "❌ Falha ao baixar extensão."
    exit 1
fi

# ============================
# Extrai extensão
# ============================

echo "📂 Extraindo arquivos..."

unzip -q "$TMP_ZIP" -d "$EXT_PATH"

# Move arquivos da subpasta "-main"
SUBDIR=$(find "$EXT_PATH" -mindepth 1 -maxdepth 1 -type d | head -n 1)

if [ -n "$SUBDIR" ] && [ -d "$SUBDIR" ]; then
    mv "$SUBDIR"/* "$EXT_PATH"/ 2>/dev/null
    mv "$SUBDIR"/.* "$EXT_PATH"/ 2>/dev/null || true
    rm -rf "$SUBDIR"
fi

# Remove ZIP temporário
rm -f "$TMP_ZIP"

# ============================
# Verifica manifest
# ============================

if [ ! -f "$EXT_PATH/manifest.json" ]; then
    echo "❌ manifest.json não encontrado em:"
    echo "   $EXT_PATH"
    exit 1
fi

# ============================
# Inicia Chrome na sessão atual
# ============================

echo "🌟 Abrindo Chrome com a extensão..."

"$CHROME_BIN" \
    --load-extension="$EXT_PATH" \
    --disable-extensions-except="$EXT_PATH" \
    --no-first-run \
    >/dev/null 2>&1 &

echo "✅ Extensão carregada com sucesso!"
echo "📂 Caminho da extensão: $EXT_PATH"
