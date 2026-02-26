# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ports,
  ...
}:
{
  imports = [ ];

  networking.hostName = "arios";
  # Seems like using networking.wireless doesn't work super well on
  # interactive systems, use networkmanager for now
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  services.inventree = {
    enable = true;

    bindIp = "0.0.0.0";
    bindPort = ports.inventree;

    config = {
      site_url = "http://arios.neon-chameleon.ts.net:${toString ports.inventree}";
      allowed_hosts = [ "*" ];
      auto_update = true;
      database = {
        ENGINE = "sqlite";
        NAME = "/var/lib/inventree/database.sqlite";
        OPTIONS = {
          # HACK: hopefully workaround database is locked errors
          # https://docs.djangoproject.com/en/dev/ref/databases/#database-is-locked-errors
          "timeout" = 600;
        };
      };
      global_settings = {
        # Disable registration, we are managing users declaratively
        LOGIN_ENABLE_REG = false;
      };
      debug = true;
      social_backends = [ ];
      social_providers = { };
      secret_key_file = ./secret_key.txt;
      static_root = "/var/lib/inventree/static";
      static_i18_root = "/var/lib/inventree/static_i18";
      media_root = "/var/lib/inventree/media";
      backup_dir = "/var/lib/inventree/backup";
      plugins_enabled = true;
    };

    plugins = {
      #inventree-kicad-plugin = [ ];
    };

    users = {
      jasper = {
        email = "jasperchan515@gmail.com";
        is_superuser = true;
        password_file = ./it_pw.txt;
      };
    };
  };

  # Should this be universal for desktop devices?
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        devices = [ ];
        config = ''
          (defsrc caps)
          (deflayer base esc)
        '';
      };
    };
  };
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "ignore";
    };
  };

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    iwmenu
    bzmenu
  ];

  virtualisation.docker.enable = true;

  # Emulated systems for building
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  systemd.sleep.extraConfig = ''
    HibernateMode=shutdown
  '';

  age.secrets = {
    jasper = {
      file = ../../secrets/jasper-arios.age;
    };
    tailscale-key = {
      file = ../../secrets/tailscale-arios.age;
    };
    wifi-env = {
      file = ../../secrets/wifi-env.age;
    };
  };

  system.stateVersion = "25.05";
}
