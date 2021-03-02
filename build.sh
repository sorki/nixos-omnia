#nix-build --cores 0 -A config.system.build.sdImage -o result-img
nix-build --cores 0 -A config.system.build.tarball -o result-medkit
