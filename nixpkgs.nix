# Pin the deployment package-set to a specific version of nixpkgs
# update with nix-prefetch-url --unpack <URL>
# - tracks nixos-20.09 branch
# - this is a default pin for deployment and shells

import (
  
  "${builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/2b973d233906fb0483263bca71bb789cad61513e.tar.gz";
    sha256 = "11h21zsas7xgdax6xs2lh3mz8spvdk8i63czysr4p69yir1h1cd7";
  }}/nixos")
