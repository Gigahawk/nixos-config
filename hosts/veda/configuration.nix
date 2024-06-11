{ config, pkgs, inputs, system, ... }:
{
  imports = [ ];

  networking.hostName = "veda";

  wsl.enable = true;
  wsl.defaultUser = "jasper";
  vscode-remote-workaround.enable = true;
  # This is disabled by default to allow
  # bootstrapping nixos-wsl
  security.sudo.wheelNeedsPassword = true;

  # Emulated systems for building
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  age.secrets = {
    jasper = {
      file = ../../secrets/jasper-veda.age;
    };
  };
  system.stateVersion = "23.11";
}
