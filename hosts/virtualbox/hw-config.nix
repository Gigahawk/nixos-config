{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };

  fileSystems."/mnt/parity0" =
    { device = "/dev/disk/by-label/parity0";
      fsType = "ext4";
      options = [
        "defaults"
        "errors=remount-ro"
      ];
    };

  fileSystems."/mnt/data0" =
    { device = "/dev/disk/by-label/data0";
      fsType = "ext4";
      options = [
        "defaults"
        "errors=remount-ro"
      ];
    };

  fileSystems."/mnt/data1" =
    { device = "/dev/disk/by-label/data1";
      fsType = "ext4";
      options = [
        "defaults"
        "errors=remount-ro"
      ];
    };

  fileSystems."/mnt/data2" =
    { device = "/dev/disk/by-label/data2";
      fsType = "ext4";
      options = [
        "defaults"
        "errors=remount-ro"
      ];
    };
  
  fileSystems."/mnt/pool" =
    { device = "/mnt/data*";
      fsType = "fuse.mergerfs";
      options = [
        "defaults"
        "allow_other"
        "cache.files=off"
        "moveonenospc=true"
      ];
    };
  
  # Set global rw on data drives
  systemd.tmpfiles.rules = [
    "d /mnt/data0 0777 root root"
    "d /mnt/data1 0777 root root"
    "d /mnt/data2 0777 root root"
    "d /mnt/pool 0777 root root"
    # TODO: this should probably be owned by a inventree user?
    "d /mnt/pool/inventree-data 0777 root root"

    # TODO: this should probably be owned by a immich user?
    "d /mnt/pool/immich 0777 root root"
    "d /mnt/pool/immich/data 0777 root root"
    "d /mnt/pool/immich/config 0777 root root"
    "d /mnt/pool/immich/photos 0777 root root"
    "d /mnt/pool/immich/config/machine-learning 0777 root root"
  ];

  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  virtualisation.virtualbox.guest.enable = true;
}

