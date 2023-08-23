# edit this configuration file to define what should be installed on
# your system.  help is available in the configuration.nix(5) man page
# and in the nixos manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports = [ ];

  virtualisation.arion = {
    backend = "docker";
    projects = 
    let
      inventree_version = "0.12.6";
      inventree_web_port = "1337";
      inventree_db_name = "inventree";
      inventree_db_port = "5432";
      inventree_db_user = "pguser";
      inventree_db_password = "pgpassword";
      inventree_cache_port = "6379";
      inventree_data_path = /mnt/pool/inventree-data;
      inventree_data_volumes = [
        "${toString inventree_data_path}:/home/inventree/data"
      ];
      inventree_environment = {
        INVENTREE_EXT_VOLUME = "${toString inventree_data_path}";

        INVENTREE_WEB_PORT = inventree_web_port;

        INVENTREE_DEBUG = "False";
        INVENTREE_LOG_LEVEL = "WARNING";

        INVENTREE_DB_ENGINE = "postgresql";
        INVENTREE_DB_NAME = inventree_db_name;
        INVENTREE_DB_HOST = "inventree-db";
        INVENTREE_DB_PORT = inventree_db_port;

        INVENTREE_DB_USER = inventree_db_user;
        INVENTREE_DB_PASSWORD = inventree_db_password;

        #INVENTREE_CACHE_HOST = "inventree-cache";
        #INVENTREE_CACHE_PORT = inventree_cache_port;

        INVENTREE_GUNICORN_TIMEOUT = 90;

        INVENTREE_PLUGINS_ENABLED = "True";

        INVENTREE_TAG = inventree_version;

        COMPOSE_PROJECT_NAME = "inventree-production";
      };
    in
    {
      inventree.settings = {
        services = {
          inventree-db.service = {
            image = "postgres:13";
            expose = ["${inventree_db_port}/tcp"];
            environment = {
              PGDATA = "/var/lib/postgresql/data/pgdb";
              POSTGRES_USER = inventree_db_user;
              POSTGRES_PASSWORD= inventree_db_password;
              POSTGRES_DB= inventree_db_name;
            };
            volumes = [
              "${toString inventree_data_path}:/var/lib/postgresql/data"
            ];
            restart = "unless-stopped";
          };
          inventree-cache.service = {
            image = "redis:7.0";
            depends_on = ["inventree-db"];
            environment = inventree_environment;
            expose = [inventree_cache_port];
            restart = "always";
          };
          inventree-server.service = {
            image = "inventree/inventree:${inventree_version}";
            expose = ["8000"];
            depends_on = ["inventree-db"];
            environment = inventree_environment;
            restart = "unless-stopped";
            volumes = inventree_data_volumes;
          };
          inventree-worker.service = {
            image = "inventree/inventree:${inventree_version}";
            command = "invoke worker";
            depends_on = ["inventree-server"];
            environment = inventree_environment;
            volumes = inventree_data_volumes;
          };
          inventree-proxy.service = {
            image = "nginx:stable";
            depends_on = ["inventree-server"];
            environment = inventree_environment;
            ports = ["${inventree_web_port}:80"];
            volumes = [
              # TODO: figure out how to include this
              #"./nginx.prod.conf:/etc/nginx/conf.d/default.conf:ro"
              "${toString inventree_data_path}:/var/www"
            ];
            restart = "unless-stopped";
          };
        };
      };
    };
  };

  # use the systemd-boot efi boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "virtualbox";

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # This is a server, disable sleep
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
  ];

  systemd.services.snapraid_sync = {
    serviceConfig.Type = "oneshot";
    path = [
      pkgs.msmtp
      pkgs.snapraid
    ];
    script = builtins.readFile ./snapraid_sync.sh;
  };
  systemd.timers.snapraid_sync = {
    wantedBy = [ "timers.target" ];
    partOf = [ "snapraid_sync.service" ];
    # TODO: Change this to once a week or something
    timerConfig.OnCalendar = [ "*-*-* 00:00:00" ];
  };

  snapraid = {
    enable = true;
    dataDisks = {
      d0 = "/mnt/data0";
      d1 = "/mnt/data1";
      d2 = "/mnt/data2";
    };
    # disable maintenance services, handle using our own service
    sync.interval = "1970-01-01";
    scrub.interval = "1970-01-01";
    parityFiles = [
      "/mnt/parity0/snapraid0.parity"
    ];
    contentFiles = [
      "/var/snapraid.content"
      "/mnt/data0/snapraid.content"
      "/mnt/data1/snapraid.content"
      "/mnt/data2/snapraid.content"
    ];
    exclude = [
      "/lost+found/"
    ];
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

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
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = Samba %v on (%h)

      # idk if this needs to be set
      # netbios name = virtualbox

      # isn't this set by securityType?
      # security = user

      # idk disabled in the example
      # use sendfile = yes
      # max protocol = smb2

      hosts allow = 192.168.1. 192.168.0. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0

      guest account = jasper
      map to guest = bad user
    '';
    shares = {
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
  };

}


