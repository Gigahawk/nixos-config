{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "nct6775" ];
  boot.kernelParams = [
    "i915.enable_guc=3"
  ];
  boot.extraModulePackages = [ ];

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override {
      enableHybridCodec = true;
    };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      intel-compute-runtime
      libvdpau-va-gl
    ];
  };

  # Is this necessary?
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

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

  #fileSystems."/mnt/data2" =
  #  { device = "/dev/disk/by-label/data2";
  #    fsType = "ext4";
  #    options = [
  #      "defaults"
  #      "errors=remount-ro"
  #    ];
  #  };

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
    "d /mnt/parity0 0777 root root"
    "d /mnt/data0 0777 root root"
    "d /mnt/data1 0777 root root"
    #"d /mnt/data2 0777 root root"
    "d /mnt/pool 0777 root root"
    # TODO: this should probably be owned by a inventree user?
    "d /mnt/pool/inventree-data 0775 inventree inventree"
    "d /mnt/pool/inventree-data/static 0775 inventree inventree"
    "d /mnt/pool/inventree-data/static_i18 0775 inventree inventree"
    "d /mnt/pool/inventree-data/media 0775 inventree inventree"
    "d /mnt/pool/inventree-data/backup 0775 inventree inventree"
    "d /mnt/pool/inventree-data/git-backup 0775 inventree inventree"
    # Syncthing dirs
    #"d /mnt/pool/test-folder 0777 root root"

    # TODO: this should probably be owned by a immich user?
    "d /mnt/pool/immich 0777 root root"
    "d /mnt/pool/immich/data 0777 root root"
    "d /mnt/pool/immich/config 0777 root root"
    "d /mnt/pool/immich/photos 0777 root root"
    "d /mnt/pool/immich/config/machine-learning 0777 root root"

    # Printing over samba
    "d /var/spool/samba 1777 root root -"
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
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

