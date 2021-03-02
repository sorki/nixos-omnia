{ config, pkgs, lib, modulesPath, ... }:
{
  nixpkgs.overlays = [
    (import ./overlay.nix)
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
}
