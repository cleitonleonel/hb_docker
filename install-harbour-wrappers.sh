#!/bin/bash

BINS=("hbmk2" "hbrun" "hbformat" "harbour")

for bin in "${BINS[@]}"; do
    echo "#!/bin/bash" > $bin
    echo "docker exec -it harbour-sdk $bin \"\$@\"" >> $bin
    chmod +x $bin
    sudo mv $bin /usr/local/bin/
done

echo "Wrappers instalados."
