{ config, pkgs, lib, modulesPath, ... }:

{
  nixpkgs.overlays = [
    (import ./overlay.nix)
  ];

  imports = [
    "${modulesPath}/installer/cd-dvd/system-tarball.nix"
    "${modulesPath}/profiles/installation-device.nix"
    ./configuration-common.nix
  ];

  fileSystems = {
    "/" = {
      device = "/dev/mmcblk0p1";
      fsType = "btrfs";
      options = [
        "subvol=@"
        "noatime"
        "nodiratime"
        "discard=async"
      ];
    };
  };

  tarball =
    let
    extlinux-conf-builder =
      import "${modulesPath}/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix" {
        pkgs = pkgs.buildPackages;
      };

      extlinuxConf = pkgs.runCommand "tarball-extlinux.conf" {}
      ''
      mkdir $out
      ${extlinux-conf-builder} -t 3 -c ${config.system.build.toplevel} -d $out
      '';
    in
  {
    contents = [
      {
        source = "${extlinuxConf}/extlinux";
        target = "boot";
      }
      {
        source = "${extlinuxConf}/nixos";
        target = "boot";
      }
    ];

    compression = {
      command = "gzip";
      extension = ".gz";
      extraInputs = [ pkgs.gzip ];
    };
  };

  system.build.medkit = pkgs.runCommand "omnia-medkit" {}
  ''
    mkdir $out
    cp ${config.system.build.tarball}/tarball/*.tar.gz $out/omnia-medkit-nixos.tar.gz
  '';
}
