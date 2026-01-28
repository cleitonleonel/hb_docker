#!/bin/sh
set -e

# Subir containers
docker compose up -d
echo "Containers iniciados em background"

# Verificar se os wrappers já existem
NEEDED_BINS="hbmk2 hbrun hbformat harbour"
INSTALL_WRAPPERS=0

for bin in $NEEDED_BINS; do
    if ! command -v "$bin" >/dev/null 2>&1; then
        INSTALL_WRAPPERS=1
        break
    fi
done

# Instalar wrappers apenas se necessário
if [ "$INSTALL_WRAPPERS" -eq 1 ]; then
    echo "Instalando Harbour wrappers..."
    chmod +x ./install-harbour-wrappers.sh
    ./install-harbour-wrappers.sh
else
    echo "Harbour wrappers já estão instalados. Pulando etapa."
fi

# Preparar workspace
mkdir -p workspace
cd workspace || exit 1

# Compilar
echo "Compilando $1..."

hbmk2 -static "$1" "$2"

echo "Compilação concluída."
