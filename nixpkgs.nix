# update with nix-prefetch-url --unpack <URL>

import (
  "${builtins.fetchTarball {
    # XXX: switch to upstream
    url = "https://github.com/sorki/nixpkgs/archive/8e687d60ce956fe9cb5e5eba4dec901dbdc55f72.tar.gz";
    sha256 = "1nja86sfqf6k8w95h48cn3ndpg3a0blpvgnvpl8h6yxn02pq10dj";
  }}/nixos")
