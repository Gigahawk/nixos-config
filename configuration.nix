{ config, pkgs, inputs, system, ... }:

{
  imports = [ ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  nixpkgs.config.allowUnfree = true;

  boot.crashDump.enable = true;

  hardware = {
    enableAllFirmware = true;
    # TODO: do we need this?
    opengl.driSupport32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    btop
    git
    gosu
    hddtemp
    hwinfo
    jq
    lm_sensors
    lshw
    smartmontools
    syncthing
    tailscale
    tree
    vim
    wget
    xplr

    # Custom packages
    inputs.arion.packages.${system}.default
    inputs.nix-top.packages.${system}.default
  ];

  networking.firewall = {
    enable = true;
    allowPing = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedTCPPorts = [ 22 ];
  };

  services.tailscale.enable = true;
  services.automatic-timezoned.enable = true;
  services.uptimed.enable = true;

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  users.mutableUsers = false;

  system.stateVersion = "23.05";

}


