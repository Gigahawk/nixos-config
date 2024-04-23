{ config, lib, pkgs, modulesPath, ... }:
let
  rpi4-hw = fetchTarball {
    url = "https://github.com/NixOS/nixos-hardware/archive/32f61571b486efc987baca553fb35df22532ba63.tar.gz";
    sha256 = "sha256:0sf34kb40gf73zrhcy2j0jijgbzd571rfq1wzan4qa6hg04xjbhf";
  };
in
{
  #imports = [
  #  "${rpi4-hw}/raspberry-pi/4"
  #];

  #boot.kernelPackages = pkgs.linuxPackages_rpi4;

  ##boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  #boot.initrd.kernelModules = [ ];
  ##boot.kernelModules = [ "kvm-amd" ];
  #boot.extraModulePackages = [ ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };


  #swapDevices =
  #  [ { device = "/dev/disk/by-label/swap"; }
  #  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}

