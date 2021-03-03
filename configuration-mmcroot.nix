{ config, pkgs, lib, modulesPath, ... }:
{
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
}
