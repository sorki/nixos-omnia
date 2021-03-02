nix-build ./default-sdimage.nix \
    --cores 0 \
    -A config.system.build.sdImage \
    -o result-img
