#!/bin/bash
set -e

BINS=("hbmk2" "hbrun" "hbformat" "harbour")

for bin in "${BINS[@]}"; do
    cat <<EOF > "$bin"
#!/bin/bash
# Se a variável HARBOUR_CONTAINER não estiver definida, usa um padrão
CONTAINER=\${HARBOUR_CONTAINER:-harbour_sdk-18}
docker exec -i \$CONTAINER $bin "\$@"
EOF
    chmod +x "$bin"
    sudo mv "$bin" /usr/local/bin/
done

echo "Wrappers instalados."
