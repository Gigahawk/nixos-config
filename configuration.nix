{ config, pkgs, ... }:

{
  imports = [ ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  boot.crashDump.enable = true;

  hardware = {
    enableAllFirmware = true;
    # TODO: do we need this?
    opengl.driSupport32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    arion
    git
    syncthing
    tailscale
    tree
    vim
    wget
    xplr
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


