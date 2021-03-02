{ config, pkgs, lib, ... }:
{
  imports = [
    ./configuration-sdimage.nix
  ];

  nixpkgs.crossSystem = {
    system = "armv7l-linux";
  };
}
