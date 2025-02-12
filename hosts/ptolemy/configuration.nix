# edit this configuration file to define what should be installed on
# your system.  help is available in the configuration.nix(5) man page
# and in the nixos manual (accessible by running `nixos-help`).

{ config, pkgs, inputs, system, ... }:

{
  imports = [ ];

  # Sometimes to deal with issues like a web server bound only to
  # localhost it's useful to have an xserver running so that we
  # can run a web browser or whatever
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
  };

  # use the systemd-boot efi boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  virtualisation.oci-containers.backend = "docker";

  services.avahi = {
    enable = true;
    # TODO: figure out what any of this does
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
  services.printing = {
    enable = true;
    webInterface = false;
    stateless = true;
    startWhenNeeded = false;
    listenAddresses = [ "*:631" ];
    # TODO: is there a better way to secure this?
    allowFrom = [ "all" ];
    browsing = true;
    defaultShared = true;
    openFirewall = true;
    drivers = with pkgs; [
      gutenprint
      gutenprintBin
      foomatic-db-ppds-withNonfreeDb
      foo2zjs
    ];
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Xerox_WorkCentre_6015NI";
        description = "Xerox WorkCentre 6015NI";
        location = "Home";
        deviceUri = "usb://Xerox/WorkCentre%206015NI?serial=BD1028394&interface=1";
        model = "Xerox-WorkCentre_6015.ppd.gz";
        ppdOptions = {
          PageSize = "letter";
        };

      }
    ];
    ensureDefaultPrinter = "Xerox_WorkCentre_6015NI";
  };

  services.inventree = {
    enable = true;
    serverBind = "0.0.0.0:1337";
    config = {
      database = {
        ENGINE = "sqlite";
        NAME = "/mnt/pool/inventree-data/database.sqlite";
      };
      debug = true;
      social_backends = [];
      social_providers = {};
      secret_key_file = config.age.secrets.inventree-secret.path;
      static_root = "/mnt/pool/inventree-data/static";
      static_i18_root = "/mnt/pool/inventree-data/static_i18";
      media_root = "/mnt/pool/inventree-data/media";
      backup_dir = "/mnt/pool/inventree-data/backup";
    };
    users = {
      jasper = {
        email = "jasperchan515@gmail.com";
        is_superuser = true;
        password_file = config.age.secrets.inventree-jasper.path;
      };
    };
  };
  services.inventreeBackup = {
    enable = true;
    backupPath = "/mnt/pool/inventree-data/git-backup";

    enablePush = true;
    pushRemote = "Gigahawk/inventree-backup-ptolemy";
    patFile = config.age.secrets.inventree-backup-pat.path;
  };

  services.cypress-ticket-scraper = {
    enable = true;
    dataDir = "/mnt/pool/cypress-ticket-data";
  };

  # Emulated systems for building
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  nix.settings.system-features = [
    "nixos-test"
    "benchmark"
    "big-parallel"
    "kvm"
  ];

  networking.hostName = "ptolemy";
  networking.firewall.allowedTCPPorts = [
    5357 # wsdd (some samba thing)
    19999 # netdata
    8096 # jellyfin
  ];
  networking.firewall.allowedUDPPorts = [
    3702 # wsdd (some samba thing)
  ];

  # This is a server, disable sleep
  powerManagement.enable = false;
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Reset on crash?
  systemd.watchdog = {
    device = "/dev/watchdog";
    runtimeTime = "30s";
    rebootTime = "10m";
    kexecTime = "10m";
  };

  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
  ];

  snapraidSettings = {
    dataDisks = {
      d0 = "/mnt/data0";
      d1 = "/mnt/data1";
      # d2 = "/mnt/data2";
    };
    parityFiles = [
      "/mnt/parity0/snapraid0.parity"
    ];
    stopServices = [
      # Immich is constantly accessing postgres which will throw warnings
      # TODO: find out if the server will recover on it's own if we only shut
      # off postgres
      "docker-immich-server.service"
      "docker-immich-db.service"
      "docker-immich-cache.service"
    ];
  };


  syncthingSettings = {
    guiPassword = "$2a$10$mPe007buYdatkjXt9w71cu8XBuBACsAHgQ0oLEfacIqUeNOt6Dok6";
    folders = {
      Music.path = "/mnt/pool/Music";
      Documents.path = "/mnt/pool/Documents";
      Homework.path = "/mnt/pool/Homework";
      remarkable_sync.path = "/mnt/pool/remarkable_sync";
      pdf2remarkable.path = "/mnt/pool/pdf2remarkable";
    };
  };

  services.samba-wsdd.enable = true;
  services.samba = {
    enable = true;
    package = pkgs.sambaFull;
    openFirewall = true;
    securityType = "user";
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "Samba %v on (%h)";
        "server role" = "standalone server";

        # idk if this needs to be set
        # netbios name = ptolemy

        # isn't this set by securityType?
        # security = user

        # idk disabled in the example
        # use sendfile = yes
        # max protocol = smb2

        # Printing
        "load printers" = "yes";
        "printing" = "cups";
        "printcap name" = "cups";

        "hosts allow" = "0.0.0.0/0";
        # hosts allow = 192.168.1. 192.168.0. 192.168.56. 127.0.0.1 localhost
        # hosts deny = 0.0.0.0/0

        # guest account = jasper
        # map to guest = bad user
      };

    };
    shares = {
      pool = {
        path = "/mnt/pool";
        browseable = "yes";
        "read only" = "no";
        #"guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        #"force user" = "username";
        #"force group" = "groupname";
      };
      printers = {
        comment = "All Printers";
        path = "/var/spool/samba";
        public = "yes";
        browseable = "yes";
        "guest ok" = "yes";
        writable = "no";
        printable = "yes";
        "create mode" = 0700;
      };
    };
  };

  services.immich-oci = {
    enable = true;
    dataPath = "/mnt/pool/immich";
    dbPath = "/mnt/pool/immich/data";
    dbCredentialsFile = config.age.secrets.immich-db-creds.path;
  };

  #services.nginx = {
  #  enable = true;
  #  virtualHosts."ptolemy.neon-chameleon.ts.net" = {
  #    locations."/inventree/" = {
  #      return = "301 $scheme://$host:1337$request_uri";
  #    };
  #    # enableACME = true;
  #    # forceSSL = true;
  #  };
  #};

  services.netdata = {
    enable = true;
    config = {
      global = {
        # uncomment to reduce memory to 32 MB
        #"page cache size" = 32;

        # update interval
        "update every" = 1;
      };
      web = {
        "default port" = 19999;
      };
      ml = {
        # enable machine learning
        "enabled" = "yes";
      };
      plugins = {
        "python.d" = "yes";
      };
    };
    configDir = {
      "python.d/smartd_log.conf" = pkgs.writeText "smartd_log.conf" ''
        log_path: '/var/log/smartd/'
      '';
    };
    python.enable = true;
  };

  services.gitea = {
    enable = true;
    appName = "Gigahawk's Gitea Server";
    stateDir = "/mnt/pool/gitea";
    lfs = {
      enable = true;
    };
    settings = {
      indexer = {
        # Workaround for putting stateDir on MergerFS
        # https://github.com/go-gitea/gitea/issues/11154#issuecomment-635559118
        ISSUE_INDEXER_PATH = "/mnt/pool/gitea/data/indexers/issues.bleve";
        ISSUE_INDEXER_TYPE = "db";
      };
      server = {
        HTTP_PORT = 3001;
        DOMAIN = "ptolemy";
      };
    };
  };

  power.ups = {
    enable = true;
    ups."apc-back-ups" = {
      driver = "usbhid-ups";
      port = "auto";
      directives = [
        "lowbatt = 80"
      ];
    };
    users = {
      upsmon = {
        passwordFile = config.age.secrets.upsmon.path;
        upsmon = "primary";
      };
      jasper = {
        passwordFile = config.age.secrets.upsmon.path;
        actions = [ "set" "fsd" ];
        instcmds = [ "all" ];
      };
    };
    upsmon.monitor."apc-back-ups".user = "upsmon";
  };

  age.secrets = {
    #alert-outlook = {
    #  file = ../../secrets/alert-outlook.age;
    #};
    jasper = {
      file = ../../secrets/jasper-ptolemy.age;
    };
    #samba-virtualbox = {
    #  file = ../../secrets/samba-virtualbox.age;
    #  path = "/home/jasper/samba-test";
    #  mode = "777";
    #};
    syncthing-key = {
      file = ../../secrets/syncthing-key-ptolemy.age;
    };
    syncthing-cert = {
      file = ../../secrets/syncthing-cert-ptolemy.age;
    };
    tailscale-key = {
      file = ../../secrets/tailscale-ptolemy.age;
    };
    upsmon = {
      file = ../../secrets/upsmon-ptolemy.age;
    };
    xmpp-password = {
      file = ../../secrets/xmpp-password-ptolemy.age;
      group = "xmpp-alert";
      mode = "440";
    };
    xmpp-jid = {
      file = ../../secrets/xmpp-jid-ptolemy.age;
      group = "xmpp-alert";
      mode = "440";
    };
    xmpp-target-jid = {
      file = ../../secrets/xmpp-target-jid.age;
      group = "xmpp-alert";
      mode = "440";
    };
    inventree-secret = {
      file = ../../secrets/inventree-secret-ptolemy.age;
      owner = "inventree";
      group = "inventree";
    };
    inventree-backup-pat = {
      file = ../../secrets/inventree-backup-pat-ptolemy.age;
      owner = "inventree";
      group = "inventree";
    };
    inventree-jasper = {
      file = ../../secrets/inventree-jasper-ptolemy.age;
      owner = "inventree";
      group = "inventree";
    };
    immich-db-creds = {
      file = ../../secrets/immich-db-creds-ptolemy.age;
    };
    restic-environment-storj = {
      file = ../../secrets/restic-environment-storj-ptolemy.age;
    };
    restic-repository-storj = {
      file = ../../secrets/restic-repository-storj-ptolemy.age;
    };
    restic-password-storj = {
      file = ../../secrets/restic-password-storj-ptolemy.age;
    };
    wifi-env = {
      file = ../../secrets/wifi-env.age;
    };
  };

}


