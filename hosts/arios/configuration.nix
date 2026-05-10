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

  services.nix-auto-push = {
    enable = true;
    target = "ptolemy";
    targetUser = "nix-auto-push-recv";
    retryAttempts = 2;
    sshOpts = [
      "-oStrictHostKeyChecking=accept-new"
      "-i ${config.age.secrets.nix-auto-push-private-key.path}"
    ];
  };

  age.secrets = {
    jasper = {
      file = ../../secrets/jasper-arios.age;
    };
    smb-secrets-ptolemy = {
      file = ../../secrets/smb-secrets-ptolemy.age;
    };
    tailscale-key = {
      file = ../../secrets/tailscale-arios.age;
    };
    nix-auto-push-private-key = {
      file = ../../secrets/nix-auto-push-private-key.age;
      owner = config.services.nix-auto-push.serviceUser;
      group = config.services.nix-auto-push.serviceUser;
    };
    wifi-env = {
      file = ../../secrets/wifi-env.age;
    };
  };

  system.stateVersion = "25.05";
}
