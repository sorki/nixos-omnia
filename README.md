# nixos-omnia

**🚧 Work in progress 🚧**

Overlay and sample `configuration.nix` which can be used to build an installer
image or medkit tarball for [Turris Omnia](https://docs.turris.cz/hw/omnia/omnia/) router.

For support check out `#nixos-on-your-router@freenode`.

## Upgrading u-boot

For painless set-up, we need UBoot with `CONFIG_DISTRO_DEFAULTS`
which was enabled only recently. Updated version is availabe and buildable on NixOS
at https://gitlab.nic.cz/turris/turris-omnia-uboot/ in `omnia-2019` branch.

### Build

To build `u-boot-spl.kwb` use

```bash
nix-build -o result-uboot \
  -E '(import <nixpkgs> { overlays = [ (import ./overlay.nix) ]; crossSystem = "armv7l-linux"; } ).uBootOmnia'
```

Also if for some reason you've managed to break your UBoot, `./result-uboot` contains `kwboot` executable
which can load UBoot over UART.

### Prepare TFTP server

Following NixOS configuration snippet can be used to quickly set-up
private LAN using e.g. USB ethernet dongle. You can use any free interface
- make sure to replace `enp8s0u2` with your "external" interface name.

```nix
let
  extIf = "enp8s0u2";
in
{

  networking.interfaces."${extIf}" = {
    ipv4.addresses = [
      { address = "192.168.142.1"; prefixLength = 24; }
    ];
  };

  networking.firewall.allowedUDPPorts = [
    68 69 # tftp
  ];

  services.dhcpd4 = {
     enable = true;
     interfaces = [ extIf ];
     extraConfig = ''
       option routers 192.168.42.1;
       option broadcast-address 192.168.142.255;
       option subnet-mask 255.255.255.0;
       option domain-name-servers 1.1.1.1;
       subnet 192.168.142.0 netmask 255.255.255.0 {
         range 192.168.142.100 192.168.142.200;
       }
    '';
  };

  services.tftpd = {
    enable = true;
    path = "/srv/tftp";
  };
}
```

Save the snippet as file and import it from your `configuration.nix`. After switching copy UBoot from previous step to TFTP root dir:

```bash
mkdir -p /srv/tftp
cp ./result-uboot/u-boot-spl.kwb /srv/tftp/u-boot-spl.kwb
```

### Load and flash to SPI

Connect your external interface to WAN port on the Omnia, reset, break boot when prompted and
issue following commands:

```
dhcp
setenv serverip 192.168.142.1
tftpboot ${kernel_addr_r} u-boot-spl.kwb

sf probe
sf update ${kernel_addr_r} 0 ${filesize}
```

## Building medkit tarball

To build either natively or using cross compilation toolchain, use

```
./build-medkit.sh
```

### Loading

Format flash drive, it absolutely needs to have at least one partition on it.

```
mkfs.btrfs /dev/sdXY
mount /dev/sdXY /mnt
cp ./result-medkit/*.tar.gz /mnt/
umount /mnt
```

Plug into Omnia, hold reset for 4 seconds (4 leds on) which starts
recovery mode which then copies contents of medkit tarball to MMC.

### UBoot shell

After medkit does its job, break into UBoot shell and issue

```
sysboot mmc 0:1 any ${scriptaddr} /@/boot/extlinux/extlinux.conf
```

to boot from NixOS installed on MMC.

To make this permanent, use

```
setenv bootmcd sysboot mmc 0:1 any ${scriptaddr} /@/boot/extlinux/extlinux.conf
saveenv
```

Now you're pretty much done with bootstrapping. Set-up SSH keys or root password
and deploy new configuration remotely.

## Building the installer SD image

### 🚧 Warning 🚧

While the installer SD image boots automatically, you probably cannot use
it to install NixOS using `nixos-install`. While `nixos-generate-config`
works correctly, there are no `armv7l` binary cache ~~and the device
might not have enough memory to perform evaluation and installation~~.
There are couple of [hardware variants](https://docs.turris.cz/hw/omnia/revisions/), some have 2GB memory.

Installer image can still be useful for remote bootstrapping using `x86` or `armv7l` machine.

### Build

To build either natively or using cross compilation toolchain, use

```
./build-sdimage.sh
```

## Flashing the installer

```
dd if=result-img/sd-image/nixos-omnia-sd-image-20.09pre-git-armv7l-linux.img \
   of=/dev/sdXY \
   bs=1M
```

## Installation

Proceed according to standard NixOS installation instructions.

In `configuration.nix`, make sure you enable at least

```nix
boot.initrd.supportedFilesystems = [ "btrfs" ];
```

If using cross-compiled installer the initial installation might take several days
as Nix cannot reuse cross-compiled packages from installers `/nix/store` and
has to build whole world from scratch including bootstrap packages. Make sure to
supply additional cooling or limit the compilation to 3 cores with `--option cores 3`.
