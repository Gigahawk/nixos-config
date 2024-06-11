{ config, pkgs, inputs, system, ... }:
{
  imports = [ ];

  wsl.enable = true;
  wsl.defaultUser = "jasper";

  networking.hostName = "veda";

  # This is disabled by default to allow
  # bootstrapping nixos-wsl
  security.sudo.wheelNeedsPassword = true;

  age.secrets = {
    jasper = {
      file = ../../secrets/jasper-veda.age;
    };
  };
  system.stateVersion = "23.11";
}