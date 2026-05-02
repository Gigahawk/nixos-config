# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  ports = import ../../ports.nix;
in
{
  imports = [ ];

  nix.settings = {
    substituters = [
      # Default nixpkgs cache has a priority of 40 (lower value is queried first)
      # Use default nixpkgs cache where possible
      "http://ptolemy.neon-chameleon.ts.net:${toString ports.nix-serve-external}?priority=50"
    ];
    trusted-public-keys = [
      (builtins.readFile ../../secrets/nix-serve-public-key-ptolemy.pem.pub)
    ];
    # Default behavior seems to be a timeout after 15s and 5 reconnect attempts?
    # Takes forever
    download-attempts = 3;
    connect-timeout = 3;
    # If this is not true the build will completely fail
    # if any substituter is unavailable.
    # Even with this true the behavior is kind of jank
    # since the first failure will invoke a fallback to building
    # Relevant discussions:
    # https://github.com/NixOS/nix/pull/13301
    # https://github.com/NixOS/nix/issues/15419
    fallback = true;
  };

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
    wifi-env = {
      file = ../../secrets/wifi-env.age;
    };
  };

  system.stateVersion = "25.05";
}
