#!/bin/bash
set -e

DISTRO_VERSION=""
ARGS=()

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --distro-version)
            DISTRO_VERSION="$2"
            shift 2
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

if [ "$DISTRO_VERSION" = "18" ]; then
    SERVICE_NAME="harbour18"
    CONTAINER_NAME="harbour_sdk-18"
else
    SERVICE_NAME="harbour22"
    CONTAINER_NAME="harbour_sdk-22"
fi

docker compose up -d $SERVICE_NAME --remove-orphans

OS_NAME=$(docker exec "$CONTAINER_NAME" sh -c "grep 'PRETTY_NAME' /etc/os-release | cut -d'=' -f2 | tr -d '\"'")
LDD_VERSION=$(docker exec "$CONTAINER_NAME" ldd --version | head -n 1 | awk '{print $NF}')

echo "Container $CONTAINER_NAME iniciado em background"

export HARBOUR_CONTAINER="$CONTAINER_NAME"

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
    chmod +x ./scripts/install-harbour-wrappers.sh
    ./scripts/install-harbour-wrappers.sh
else
    echo "Harbour wrappers já estão instalados. Pulando etapa."
fi

echo "Sistema operacional do container: $OS_NAME - GLIBC version: $LDD_VERSION"

mkdir -p workspace
cd workspace || exit 1

if [ ${#ARGS[@]} -eq 0 ]; then
    echo "Nenhum arquivo para compilar. Informe os arquivos como argumento."
    exit 0
fi

FILE_NAME=$(basename "${ARGS[0]}")

echo "Compilando $FILE_NAME no container $CONTAINER_NAME..."

hbmk2 -static "${ARGS[@]}"


echo "Compilação concluída."
