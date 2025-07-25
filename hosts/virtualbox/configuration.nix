# edit this configuration file to define what should be installed on
# your system.  help is available in the configuration.nix(5) man page
# and in the nixos manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports = [ ];

  #virtualisation.oci-containers.backend = "docker";

  #virtualisation.docker.enable = true;

  ## For now all paths need to be strings?
  #services.inventree = {
  #  enable = true;

  #  serverBind = "0.0.0.0:1337";

  #  config = {
  #    database = {
  #      ENGINE = "sqlite";
  #      NAME = "/mnt/pool/inventree-test/test.sqlite";
  #    };
  #    debug = true;
  #    social_backends = [];
  #    social_providers = {};
  #    secret_key_file = config.age.secrets.inventree-secret.path;
  #    static_root = "/mnt/pool/inventree-test/static";
  #    static_i18_root = "/mnt/pool/inventree-test/static_i18";
  #    media_root = "/mnt/pool/inventree-test/media";
  #    backup_dir = "/mnt/pool/inventree-test/backup";
  #  };

  #  users = {
  #    jasper = {
  #      email = "jasperchan515@gmail.com";
  #      is_superuser = true;
  #      password_file = config.age.secrets.inventree-jasper.path;
  #    };
  #  };
  #};
  #services.inventreeBackup = {
  #  enable = true;
  #  backupPath = "/mnt/pool/inventree-test/git-backup";

  #  enablePush = true;
  #  pushRemote = "Gigahawk/inventree-test-backup";
  #  patFile = config.age.secrets.inventree-backup-pat.path;
  #};

  #services.immich = {
  #  enable = true;
  #  host = "0.0.0.0";
  #  mediaLocation = "/mnt/pool/immich-nixos";
  #};

  #services.ghidra-server = {
  #  enable = true;
  #  host = "virtualbox";
  #  directory = "/mnt/pool/ghidra-server";
  #};

  # use the systemd-boot efi boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "virtualbox";

  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "matrix";
      bigclock = "en";
      clock = "%c";
    };
  };
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.xautolock.time = 99999;

  # This is a server, disable sleep
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  environment.systemPackages = with pkgs; [
    firefox
    mergerfs
    mergerfs-tools
  ];

  snapraidSettings = {
    dataDisks = {
      d0 = "/mnt/data0";
      d1 = "/mnt/data1";
      d2 = "/mnt/data2";
    };
    parityFiles = [
      "/mnt/parity0/snapraid0.parity"
    ];
  };

  services.samba-wsdd.enable = true;
  networking.firewall.allowedTCPPorts = [
    5357 # wsdd
  ];
  networking.firewall.allowedUDPPorts = [
    3702 # wsdd
  ];
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        security = "user";

        "workgroup" = "WORKGROUP";
        "server string" = "Samba %v on (%h)";

        # idk if this needs to be set
        # netbios name = virtualbox

        # isn't this set by securityType?
        # security = user

        # idk disabled in the example
        # use sendfile = yes
        # max protocol = smb2

        "hosts allow" = "192.168.1. 192.168.0. 192.168.56. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";

        #"guest account = jasper"
        #"map to guest = bad user"

      };
      public = {
        path = "/home/jasper/share";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        #"force user" = "username";
        #"force group" = "groupname";
      };
      pool = {
        path = "/mnt/pool";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        #"force user" = "username";
        #"force group" = "groupname";
      };
    };
  };

  programs.msmtp = {
    enable = true;
    accounts.default = {
      auth = true;
      tls = true;
      tls_starttls = true;
      tls_trust_file = "/etc/ssl/certs/ca-bundle.crt";
      tls_certcheck = true;
      host = "smtp.office365.com";
      port = 587;
      from = "jaspervirtualbox@outlook.com";
      user = "jaspervirtualbox@outlook.com";
      passwordeval = "cat ${config.age.secrets.alert-outlook.path}";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."virtualbox.neon-chameleon.ts.net" = {
      locations."/inventree/" = {
        return = "301 $scheme://$host:1337$request_uri";
      };
      # enableACME = true;
      # forceSSL = true;
    };
  };

  age.secrets = {
    alert-outlook = {
      file = ../../secrets/alert-outlook.age;
    };
    jasper = {
      file = ../../secrets/jasper-virtualbox.age;
    };
    samba-virtualbox = {
      file = ../../secrets/samba-virtualbox.age;
      path = "/home/jasper/samba-test";
      mode = "777";
    };
    tailscale-key = {
      file = ../../secrets/tailscale-virtualbox.age;
    };
    xmpp-password = {
      file = ../../secrets/xmpp-password-virtualbox.age;
    };
    xmpp-jid = {
      file = ../../secrets/xmpp-jid-virtualbox.age;
    };
    xmpp-target-jid = {
      file = ../../secrets/xmpp-target-jid.age;
    };
    inventree-secret = {
      file = ../../secrets/inventree-secret-virtualbox.age;
      owner = "inventree";
      group = "inventree";
    };
    inventree-backup-pat = {
      file = ../../secrets/inventree-backup-pat-virtualbox.age;
      owner = "inventree";
      group = "inventree";
    };
    inventree-jasper = {
      file = ../../secrets/inventree-jasper-virtualbox.age;
      owner = "inventree";
      group = "inventree";
    };
    restic-environment-storj = {
      file = ../../secrets/restic-environment-storj-virtualbox.age;
    };
    restic-repository-storj = {
      file = ../../secrets/restic-repository-storj-virtualbox.age;
    };
    restic-password-storj = {
      file = ../../secrets/restic-password-storj-virtualbox.age;
    };
    wifi-env = {
      file = ../../secrets/wifi-env.age;
    };
  };

}


