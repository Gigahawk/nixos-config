{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
  ];

  boot.crashDump.enable = true;

  hardware = {
    enableAllFirmware = true;
    # TODO: do we need this?
    graphics.enable32Bit = true;
  };

  environment.systemPackages =
    with pkgs;
    [
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
      gnupg
      gopass
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
      nixfmt
      p7zip
      smartmontools
      syncthing
      tailscale
      tmux
      traceroute
      tree
      unzip
      usbutils
      vim
      wget
      xplr

      # Custom packages
      inputs.nix-top.packages.${stdenv.hostPlatform.system}.default
      inputs.hydrasect.packages.${stdenv.hostPlatform.system}.default
      (callPackage ./packages/nixos-update.nix { })
      (callPackage ./packages/nix-flake-init.nix { })
    ]
    ++ (
      if
        builtins.elem stdenv.hostPlatform.system [
          "i686-linux"
          "x86_64-linux"
          "x86_64-darwin"
        ]
      then
        [ mprime ]
      else
        [ ]
    );

  programs.zsh.enable = true;

  networking.firewall = {
    enable = true;
    allowPing = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedTCPPorts = [ 22 ];
  };

  services.tailscale = {
    enable = lib.mkDefault true;
    authKeyFile = config.age.secrets.tailscale-key.path;
    openFirewall = true;
  };
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

  services.udisks2 = {
    enable = true;
  };

  users.mutableUsers = false;

  # Gross
  programs.nano.enable = false;
  programs.neovim = {
    enable = lib.mkDefault true;
    viAlias = true;
    vimAlias = true;
  };
  environment.variables = {
    EDITOR = "nvim";
  };

  system.stateVersion = lib.mkOverride 1100 "23.05";
}
