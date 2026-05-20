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
