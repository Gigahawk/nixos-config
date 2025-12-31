{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ ];

  networking.hostName = "veda";

  nixpkgs.hostPlatform = "x86_64-linux";

  wsl.enable = true;
  wsl.defaultUser = "jasper";
  vscode-remote-workaround.enable = true;
  # This is disabled by default to allow
  # bootstrapping nixos-wsl
  security.sudo.wheelNeedsPassword = true;

  virtualisation.docker.enable = true;

  # Emulated systems for building
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  # Use tailscale via windows client
  services.tailscale.enable = false;

  age.secrets = {
    jasper = {
      file = ../../secrets/jasper-veda.age;
    };
    wifi-env = {
      file = ../../secrets/wifi-env.age;
    };
  };
  system.stateVersion = "23.11";
}
