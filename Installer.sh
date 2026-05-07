#!/bin/bash

# ============================
# Configurações
# ============================

GITHUB_REPO="https://github.com/school0102/Google-Chrome-Extension.git"
EXT_PATH="$HOME/Google-Chrome-Extension"
TEMP_PROFILE="$HOME/.chrome-temp-profile"

# Detecta o Chrome ou Chromium
CHROME_BIN=$(command -v google-chrome || command -v chromium)

# ============================
# Função principal
# ============================

echo "🚀 Instalando/atualizando extensão do GitHub..."

# Verifica se o git está instalado
if ! command -v git >/dev/null 2>&1; then
    echo "❌ Git não encontrado. Instale o Git antes de continuar."
    exit 1
fi

# Clona ou atualiza a extensão
if [ -d "$EXT_PATH" ]; then
    echo "📦 Atualizando extensão existente..."
    cd "$EXT_PATH" && git pull
else
    echo "📦 Clonando extensão..."
    git clone "$GITHUB_REPO" "$EXT_PATH"
fi

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
