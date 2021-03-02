import ./nixpkgs.nix {
  configuration =
    if builtins.currentSystem == "armv7l-linux"
    then builtins.toPath (./. + "/configuration.nix")
    else builtins.toPath (./. + "/with-cross.nix")
  ;
}
