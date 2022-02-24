{
  description = "System Config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    inherit (nixpkgs) lib;

    util = import ./lib {
      inherit system pkgs home-manager lib; overlays = (pkgs.overlays);
    };

    inherit (util) user;
    inherit (util) host;

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [];
    };

    system = "x86_64-linux";
  in {

    homeManagerConfigurations = {
      jasper = user.mkHMUser {

      };
    };

    nixosConfigurations = {
      nixosVbox = host.mkHost {
        name = "nixosVbox";
        NICs = [ "enp0s3" ];
        kernelPackage = pkgs.linuxPackages;
        initrdMods = [ "ata_piix" "ohci_pci" "sd_mod" "sr_mod" ];
        kernelMods = [];
        kernelParams = [];
        systemConfig = {
          # your abstracted system config
        };
        users = [{
          name = "jasper";
          groups = [ "wheel" "networkmanager" "video" ];
          uid = 1000;
          shell = pkgs.zsh;
        }];
        cpuCores = 6;
      };
      arios = host.mkHost {
        name = "arios";
        NICs = [ "enp0s31f6" "wlp2s0" ];
        kernelPackage = pkgs.linuxPackages;
        initrdMods = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
        kernelMods = [ "wl" ];
        kernelParams = [];
        systemConfig = {
          # your abstracted system config
        };
        users = [{
          name = "jasper";
          groups = [ "wheel" "networkmanager" "video" ];
          uid = 1000;
          shell = pkgs.zsh;
        }];
        cpuCores = 4;
      };
    };
  };
}
