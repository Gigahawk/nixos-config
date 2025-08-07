{ config, lib, pkgs, inputs, system, ... }:

{
  imports = [ ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (import ./overlays/yt-dlp.nix)
  ];

  boot.crashDump.enable = true;

  hardware = {
    enableAllFirmware = true;
    # TODO: do we need this?
    graphics.enable32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    alejandra
    bat
    binwalk
    btop
    bmon
    cryptsetup
    dig
    dua
    dmidecode
    dos2unix
    evtest
    expect
    fastfetch
    ffmpeg
    file
    gdu
    git
    git-lfs
    gosu
    hddtemp
    hwinfo
    i2c-tools
    imagemagick
    jq
    lm_sensors
    lshw
    nethogs
    nix-output-monitor
    nix-tree
    nixfmt-rfc-style
    p7zip
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
    yt-dlp

    # Custom packages
    inputs.nix-top.packages.${system}.default
    (callPackage ./packages/nixos-update.nix { })
  ] ++ (
    if builtins.elem system [ "i686-linux" "x86_64-linux" "x86_64-darwin"] then
      [ mprime ]
    else
      []
  );

  networking.firewall = {
    enable = true;
    allowPing = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedTCPPorts = [ 22 ];
  };

  services.tailscale.enable = true;
  services.localtimed.enable = true;
  services.geoclue2.enable = true;
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
    secretsFile = config.age.secrets.wifi-env.path;
    networks = {
      gameboy.pskRaw = "ext:GAMEBOY_PASS";
      gameboy-5GHz.pskRaw = "ext:GAMEBOY_PASS";
    };
  };

  users.mutableUsers = false;

  system.stateVersion = lib.mkOverride 1100 "23.05";

}


