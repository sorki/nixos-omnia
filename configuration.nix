{ config, pkgs, lib, modulesPath, ... }:

{
  nixpkgs.overlays = [
    (import ./overlay.nix)
  ];

  imports = [
    # "${modulesPath}/installer/cd-dvd/sd-image.nix"
    "${modulesPath}/installer/cd-dvd/system-tarball.nix"
    "${modulesPath}/profiles/installation-device.nix"
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible = {
    enable = true;
    configurationLimit = 30;
  };

  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.consoleLogLevel = 7;
  boot.kernelParams = [
    "boot.shell_on_fail"
    "earlyprintk"
    "console=ttyS0,115200"
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPatches = [ {
        name = "crashdump-config";
        patch = null;
        extraConfig = ''
                CRASH_DUMP y
                DEBUG_INFO y
                PROC_VMCORE y
                LOCKUP_DETECTOR y
                HARDLOCKUP_DETECTOR y
              '';
        } ];
  system.stateVersion = "20.09";

  environment.systemPackages = with pkgs; [
    wget screen vim

    usbutils
    # more cross issues
    # https://github.com/NixOS/nixpkgs/pull/86645
    #libgpiod
    #powertop
    #lm_sensors
  ];

  # minification
  security.polkit.enable = false;
  services.udisks2.enable = lib.mkForce false;

  # omnia new

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
        source = extlinuxConf;
        target = "/boot/extlinux/extlinux.conf";
      }
    ];

    compression = {
      command = "gzip";
      extension = ".gz";
      extraInputs = [ pkgs.gzip ];
    };
  };

  # unused
  /*
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
  */

}
