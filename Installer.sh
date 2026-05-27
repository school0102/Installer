# ============================
# Inicia com extensão (SINGLE LINE METHOD)
# ============================

echo "🚀 Iniciando Chrome em modo debug..."

"$CHROME_BIN" --user-data-dir="$USER_DATA_DIR" --load-extension="$EXT_PATH" --no-first-run
