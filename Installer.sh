#!/bin/bash

# ============================
# Configurações
# ============================

ZIP_URL="https://github.com/school0102/Google-Chrome-Extension/archive/refs/heads/main.zip"
EXT_PATH="$HOME/Google-Chrome-Extension"
TEMP_PROFILE="$HOME/.chrome-temp-profile"
TMP_ZIP="/tmp/extension.zip"

# Detecta o Chrome ou Chromium
CHROME_BIN=$(command -v google-chrome || command -v chromium)

# ============================
# Baixa e extrai a extensão
# ============================

echo "🚀 Instalando/atualizando extensão do GitHub..."

# Cria pasta de destino se não existir
mkdir -p "$EXT_PATH"

# Baixa o ZIP do GitHub
echo "📦 Baixando extensão..."
curl -L "$ZIP_URL" -o "$TMP_ZIP"

# Remove conteúdo antigo para evitar conflito
rm -rf "$EXT_PATH"/*

# Extrai ZIP
echo "📂 Extraindo arquivos..."
unzip -q "$TMP_ZIP" -d "$EXT_PATH"

# O GitHub coloca tudo dentro de uma subpasta com '-main', vamos mover para EXT_PATH
SUBDIR=$(find "$EXT_PATH" -mindepth 1 -maxdepth 1 -type d | head -n 1)
if [ -d "$SUBDIR" ]; then
    mv "$SUBDIR"/* "$EXT_PATH"/
    rm -rf "$SUBDIR"
fi

# Remove ZIP temporário
rm "$TMP_ZIP"

# Verifica se o manifest.json existe
if [ ! -f "$EXT_PATH/manifest.json" ]; then
    echo "❌ Arquivo manifest.json não encontrado em $EXT_PATH"
    exit 1
fi

# Checa se o Chrome está instalado
if [ -z "$CHROME_BIN" ]; then
    echo "❌ Chrome ou Chromium não encontrado. Instale antes de continuar."
    exit 1
fi

# ============================
# Fecha instâncias abertas do Chrome
# ============================

echo "🛑 Fechando instâncias abertas do Chrome (se houver)..."
pkill -f "$CHROME_BIN" 2>/dev/null || true
sleep 3

# ============================
# Cria perfil temporário
# ============================

if [ ! -d "$TEMP_PROFILE" ]; then
    echo "🗂️ Criando perfil temporário em $TEMP_PROFILE..."
    mkdir -p "$TEMP_PROFILE"
fi

# ============================
# Executa o Chrome com a extensão
# ============================

echo "🌟 Abrindo Chrome com a extensão em modo desenvolvedor..."
"$CHROME_BIN" \
    --user-data-dir="$TEMP_PROFILE" \
    --load-extension="$EXT_PATH" \
    --auto-open-devtools-for-tabs \
    --disable-extensions-except="$EXT_PATH" \
    --no-first-run \
    >/dev/null 2>&1 &

echo "✅ Chrome iniciado com a extensão!"
