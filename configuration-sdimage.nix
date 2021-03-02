{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/sd-image.nix"
    "${modulesPath}/profiles/installation-device.nix"
    ./configuration-common.nix
  ];

  sdImage =
  let
    extlinux-conf-builder =
      import "${modulesPath}/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix" {
        pkgs = pkgs.buildPackages;
      };
  in
  {
    # causes bzip2 compression of image already compressed by zstd
    compressImage = false;

    imageBaseName = "nixos-omnia-sd-image";

    populateFirmwareCommands = ''
      '';
    populateRootCommands = ''
        mkdir -p ./files/boot
        ${extlinux-conf-builder} -t 3 -c ${config.system.build.toplevel} -d ./files/boot
      '';
  };
}
