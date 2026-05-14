# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ];

  networking.hostName = "arios";
  # Seems like using networking.wireless doesn't work super well on
  # interactive systems, use networkmanager for now
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  fileSystems."/mnt/ptolemy".enable = true;

  # Should this be universal for desktop devices?
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        devices = [ ];
        config = ''
          (defsrc caps)
          (deflayer base esc)
        '';
      };
    };
  };
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "ignore";
    };
  };

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    iwmenu
    bzmenu
  ];

  virtualisation.docker.enable = true;

  # Emulated systems for building
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  systemd.sleep.settings.Sleep = {
    HibernateMode = "shutdown";
  };

  syncthingSettings = {
    guiPassword = "$2a$10$eTxUOucXaa8PJomSm0C3UO4XO3m.qCvShrqU.8GVOZRczh8W/WS7K";
    folders = {
      Music.path = "/home/jasper/Music";
      Documents.path = "/home/jasper/Documents";
      Homework.path = "/home/jasper/Homework";
      remarkable_sync.path = "/home/jasper/remarkable_sync";
      pdf2remarkable.path = "/home/jasper/pdf2remarkable";
    };
  };

  age.secrets = {
    jasper = {
      file = ../../secrets/jasper-arios.age;
    };
    syncthing-key = {
      file = ../../secrets/syncthing-key-arios.age;
    };
    syncthing-cert = {
      file = ../../secrets/syncthing-cert-arios.age;
    };
    smb-secrets-ptolemy = {
      file = ../../secrets/smb-secrets-ptolemy.age;
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
