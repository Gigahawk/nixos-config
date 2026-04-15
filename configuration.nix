{
  config,
  lib,
  pkgs,
  inputs,
  desktop ? false,
  ...
}:
{
  imports = [
    inputs.nix-index-database.nixosModules.default
    ./packages-all.nix
  ]
  ++ (if desktop then [ ./packages-desktop.nix ] else [ ]);

  programs.nix-index-database.comma.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    trusted-users = [
      "root"
      "@wheel"
    ];

    download-buffer-size = 4194304000;
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
  ];

  boot.crashDump.enable = true;

  environment.enableAllTerminfo = true;

  hardware = {
    enableAllFirmware = true;
    # TODO: do we need this?
    graphics.enable32Bit = true;
  };

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
    extraUpFlags = [
      "--operator=jasper"
    ];
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

  security.polkit.enable = true;

  hardware.keyboard.qmk = {
    enable = true;
    keychronSupport = true;
  };

  fileSystems."/mnt/ptolemy" = {
    enable = lib.mkDefault false;
    device = "//ptolemy/pool";
    fsType = "cifs";
    options =
      let
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
        smb_opts = "vers=3.0,sec=ntlmssp";
        uid = toString config.users.users.jasper.uid;
        gid = toString config.users.groups.users.gid;
        creds = config.age.secrets.smb-secrets-ptolemy.path;
      in
      [
        "${automount_opts},${smb_opts},credentials=${creds},uid=${uid},gid=${gid}"
      ];
  };

  programs.ydotool = {
    enable = desktop;
  };

  programs.git = {
    enable = true;
    config = {
      init = {
        defaultBranch = "master";
      };
      push = {
        autoSetupRemote = true;
      };
    };
  };

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
