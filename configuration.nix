{ config, lib, pkgs, inputs, system, ... }:

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
    graphics.enable32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    bat
    binwalk
    btop
    dmidecode
    evtest
    fastfetch
    ffmpeg
    git
    gosu
    hddtemp
    hwinfo
    i2c-tools
    jq
    lm_sensors
    lshw
    mprime
    nix-output-monitor
    nix-tree
    smartmontools
    syncthing
    tailscale
    traceroute
    tree
    unzip
    usbutils
    vim
    wget
    xplr

    # Custom packages
    inputs.nix-top.packages.${system}.default
    (callPackage ./packages/nixos-update.nix { })
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

  networking.wireless = {
    environmentFile = config.age.secrets.wifi-env.path;
    networks = {
      gameboy.psk = "@GAMEBOY_PASS@";
      gameboy-5GHz.psk = "@GAMEBOY_PASS@";
    };
  };

  users.mutableUsers = false;

  system.stateVersion = lib.mkDefault "23.05";

}


