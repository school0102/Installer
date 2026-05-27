#!/bin/bash

# ============================
# Configurações Estáveis
# ============================
# Using the definitive raw repository archive URL format
ZIP_URL="https://github.com"
EXT_PATH="$HOME/Google-Chrome-Extension"
TMP_ZIP="$HOME/extension_download.zip"
USER_DATA_DIR="$HOME/Chrome-Dev-Profile"

# Detecta Chrome/Chromium
CHROME_BIN=$(command -v google-chrome || command -v chromium || command -v chromium-browser)

# ============================
# Verificações
# ============================
if [ -z "$CHROME_BIN" ]; then
    echo "❌ Chrome/Chromium não encontrado."
    read -p "Pressione Enter para fechar..."
    exit 1
fi

for cmd in curl unzip; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ $cmd não encontrado."
        read -p "Pressione Enter para fechar..."
        exit 1
    fi
done

# ============================
# Baixar extensão
# ============================
echo "📦 Baixando extensão..."

mkdir -p "$EXT_PATH"
rm -rf "$EXT_PATH"/*
rm -f "$TMP_ZIP"

# Using -L to follow redirects and forcing output to user home folder
curl -L -sS "$ZIP_URL" -o "$TMP_ZIP"

if [ ! -f "$TMP_ZIP" ] || [ ! -s "$TMP_ZIP" ]; then
    echo "❌ Falha ao baixar ZIP."
    read -p "Pressione Enter para fechar..."
    exit 1
fi

# ============================
# Extrair extensão
# ============================
echo "📂 Extraindo..."

# Unzip into your home directory location instead of /tmp
unzip -q "$TMP_ZIP" -d "$EXT_PATH"

# Reposition files if GitHub wrapped them in a root folder
SUBDIR=$(find "$EXT_PATH" -mindepth 1 -maxdepth 1 -type d | head -n 1)

if [ -d "$SUBDIR" ]; then
    shopt -s dotglob
    mv "$SUBDIR"/* "$EXT_PATH"/ 2>/dev/null
    shopt -u dotglob
    rm -rf "$SUBDIR"
fi

rm -f "$TMP_ZIP"

if [ ! -f "$EXT_PATH/manifest.json" ]; then
    echo "❌ manifest.json não encontrado após a extração."
    read -p "Pressione Enter para fechar..."
    exit 1
fi

# ============================
# Fecha instâncias antigas
# ============================
echo "🛑 Fechando instâncias antigas do Chrome..."
pkill -9 -f chrome 2>/dev/null || true
pkill -9 -f chromium 2>/dev/null || true
sleep 2

# ============================
# Inicia com extensão
# ============================
echo "🚀 Iniciando Chrome em primeiro plano..."
echo "⚠️  NÃO FECHE ESTE TERMINAL. Veja os logs abaixo se houver falhas:"
echo "--------------------------------------------------------"

"$CHROME_BIN" --user-data-dir="$USER_DATA_DIR" --load-extension="$EXT_PATH" --no-first-run

echo "--------------------------------------------------------"
echo "ℹ️  O processo do Chrome terminou."
read -p "Pressione [ENTER] para encerrar este terminal..."
