# ============================
# Inicia com extensão
# ============================

echo "🚀 Iniciando Chrome com a extensão..."

# O uso da barra invertida '\' no final de cada linha é OBRIGATÓRIO 
# para o Linux entender que é o mesmo comando continuado embaixo.
"$CHROME_BIN" \
    --user-data-dir="$USER_DATA_DIR" \
    --load-extension="$EXT_PATH" \
    --restore-last-session \
    --no-first-run \
    >/dev/null 2>&1 &

echo "✅ Extensão carregada com sucesso!"
