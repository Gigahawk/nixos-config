# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [];

  networking.hostName = "arios";
  # Seems like using networking.wireless doesn't work super well on
  # interactive systems, use networkmanager for now
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  # PC/GUI stuff
  # TODO: migrate to another file
  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "matrix";
      bigclock = "en";
      clock = "%c";
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        devices = [];
        config = ''
          (defsrc caps)
          (deflayer base esc)
        '';
      };
    };
  };

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    firefox
    kitty
  ];

  virtualisation.docker.enable = true;

  # Emulated systems for building
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  age.secrets = {
    jasper = {
      file = ../../secrets/jasper-arios.age;
    };
    tailscale-key = {
      file = ../../secrets/tailscale-arios.age;
    };
    wifi-env = {
      file = ../../secrets/wifi-env.age;
    };
  };

  system.stateVersion = "25.05";
}
