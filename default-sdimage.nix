import ./nixpkgs.nix {
  configuration =
    if builtins.currentSystem == "armv7l-linux"
    then builtins.toPath (./. + "/configuration-sdimage.nix")
    else builtins.toPath (./. + "/with-cross-sdimage.nix")
  ;
}
