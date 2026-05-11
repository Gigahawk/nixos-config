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
    inputs.agenix.nixosModules.default
    ./packages-all.nix
    ./distributed.nix
  ]
  ++ (if desktop then [ ./packages-desktop.nix ] else [ ]);

  programs.nix-index-database.comma.enable = true;

  nix = {
    optimise = {
      automatic = true;
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [
        "root"
        "@wheel"
      ];

      download-buffer-size = 4194304000;
      max-jobs = "auto";

      # Trigger garbage collection when boot disk is less than 100M
      min-free = 100 * 1024 * 1024;
      # Free until 1G is free
      max-free = 1 * 1024 * 1024 * 1024;

      trusted-public-keys = [
        (builtins.readFile ./secrets/nix-serve-public-key-ptolemy.pem.pub)
        (builtins.readFile ./secrets/nix-serve-public-key-builders.pem.pub)
      ];
      secret-key-files = [
        config.age.secrets.nix-serve-builder-private-key.path
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
  };

  systemd.services.nix-daemon.serviceConfig = {
    MemoryAccounting = true;
    MemoryHigh = "75%";
    MemoryMax = "90%";
    OOMScoreAdjust = 500;
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

  environment.etc."powerlevel10k/p10k.zsh".source = ./p10k.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    enableLsColors = true;
    histSize = 1000000;
    vteIntegration = true;

    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "pattern"
        "cursor"
        "regexp"
        "root"
        "line"
      ];
    };

    autosuggestions = {
      enable = true;
      async = true;
      strategy = [
        "match_prev_cmd"
        "completion"
      ];
    };

    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        "pip"
        "node"
        "npm"
        "command-not-found"
      ];
    };

    promptInit = ''
      # this act as your ~/.zshrc but for all users (/etc/zshrc)
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source /etc/powerlevel10k/p10k.zsh

      # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
      # Initialization code that may require console input (password prompts, [y/n]
      # confirmations, etc.) must go above this block; everything else may go below.
      # double single quotes to escape the dollar char
      if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # uncomment if you want to customize your LS_COLORS
      # https://manpages.ubuntu.com/manpages/plucky/en/man5/dir_colors.5.html
      #LS_COLORS='...'
      #export LS_COLORS
    '';
  };

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

  users = {
    mutableUsers = false;
    users.root = {
      shell = pkgs.zsh;
    };
  };

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

  programs.nix-ld.enable = true;

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

  age.secrets = {
    nix-serve-builder-private-key = {
      file = ./secrets/nix-serve-private-key-builders.age;
    };
  };
}
