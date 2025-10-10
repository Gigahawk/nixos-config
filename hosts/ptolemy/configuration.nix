# edit this configuration file to define what should be installed on
# your system.  help is available in the configuration.nix(5) man page
# and in the nixos manual (accessible by running `nixos-help`).
{
  config,
  pkgs,
  inputs,
  system,
  ...
}: {
  imports = [];

  # Sometimes to deal with issues like a web server bound only to
  # localhost it's useful to have an xserver running so that we
  # can run a web browser or whatever
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
  services.displayManager.defaultSession = "xfce";

  services.ghidra-server = {
    enable = true;
    host = "ptolemy";
    directory = "/mnt/pool/ghidra-server";
  };

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
    webInterface = true;
    stateless = true;
    startWhenNeeded = false;
    listenAddresses = ["*:631"];
    # TODO: is there a better way to secure this?
    allowFrom = ["all"];
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
  systemd.settings.Manager = {
    WatchdogDevice = "/dev/watchdog";
    RuntimeWatchdogSec = "30s";
    RebootWatchdogSec = "600s";
    KExecWatchdogSec = "600s";
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
      "postgresql.service"
      "immich-server.service"
      "immich-machine-learning.service"
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
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "Samba %v on (%h)";
        "server role" = "standalone server";
        "security" = "user";

        # idk if this needs to be set
        # netbios name = ptolemy

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
  services.samba-users = {
    enable = true;
    users = {
      jasper = {
        password_file = config.age.secrets.samba-password.path;
      };
    };
  };

  services.immich = {
    enable = true;
    host = "0.0.0.0";
    mediaLocation = "/mnt/pool/immich/photos";
    accelerationDevices = null;
    machine-learning = {
      enable = true;
    };
    settings = {
      newVersionCheck.enabled = false;
      backup.database = {
        enabled = true;
      };
      logging = {
        enabled = true;
        level = "verbose";
      };
      trash = {
        enabled = true;
      };
    };
  };
  users.users.immich = {
    extraGroups = ["video" "render"];
    home = "/var/lib/immich";
    createHome = true;
  };

  services.postgresql.dataDir = "/mnt/pool/postgres";
  # Temporarily enable postgres for backup restore
  # The extensions are needed to prevent errors when trying to restore
  #https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/services/web-apps/immich.nix
  #services.postgresql = {
  #  enable = true;
  #  #ensureDatabases = mkIf cfg.database.createDB [ cfg.database.name ];
  #  #ensureUsers = mkIf cfg.database.createDB [
  #  #  {
  #  #    name = cfg.database.user;
  #  #    ensureDBOwnership = true;
  #  #    ensureClauses.login = true;
  #  #  }
  #  #];
  #  extensions = ps: with ps; [ pgvecto-rs ];
  #  settings = {
  #    shared_preload_libraries = [ "vectors.so" ];
  #    search_path = "\"$user\", public, vectors";
  #  };
  #};

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

  services.declarative-jellyfin = {
    serverId = "dfed9c03845d44d8bb2c74f7984d7761";

    # Putting datadir in pool causes files to be owned by root for some
    # reason
    #dataDir = "/mnt/pool/jellyfin";
    #backupDir = "/mnt/pool/jellyfin/backups";

    libraries = {
      Movies = {
        enabled = true;
        contentType = "movies";
        pathInfos = [
          "/mnt/pool/Movies"
        ];
      };
      Shows = {
        enabled = true;
        contentType = "tvshows";
        pathInfos = [
          "/mnt/pool/Shows"
        ];
      };
      Music = {
        enabled = true;
        contentType = "music";
        pathInfos = [
          "/mnt/pool/Music"
        ];
      };
    };

    encoding = {
      enableHardwareEncoding = true;
      hardwareAccelerationType = "vaapi";
      enableDecodingColorDepth10Hevc = true;
      allowHevcEncoding = true;
      allowAv1Encoding = true;
      hardwareDecodingCodecs = [
        "mpeg2video"
        "h264"
        "hevc"
        "vp9"
        #"vc1"
        "av1"
      ];
    };
  };

  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    # TODO: this apparently needs to be set but we don't
    # have a real domain, is hostname good enough?
    domain = "ptolemy";
    port = 28981;
    dataDir = "/mnt/pool/paperless";
    passwordFile = config.age.secrets.paperless.path;
    consumptionDirIsPublic = true;
    configureTika = true;
    settings = {
      PAPERLESS_OCR_LANGUAGE = "eng";
      PAPERLESS_OCR_USER_ARGS = {
        deskew = true;
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
    };
  };

  power.ups = {
    enable = true;
    ups."apc-back-ups" = {
      driver = "usbhid-ups";
      port = "auto";
      directives = [
        "ignorelb"
        "override.battery.charge.warning = 90"
        "override.battery.charge.low = 80"
        "override.battery.runtime.low = 600"
      ];
    };
    users = {
      upsmon = {
        passwordFile = config.age.secrets.upsmon.path;
        upsmon = "primary";
      };
      jasper = {
        passwordFile = config.age.secrets.upsmon.path;
        actions = ["set" "fsd"];
        instcmds = ["all"];
      };
    };
    upsmon.monitor."apc-back-ups".user = "upsmon";
    upsmon.settings = {
      MINSUPPLIES = 1;
      NOTIFYCMD = "${pkgs.writers.writeBash "upsmon-notify" ''
        NL=$'\n'
        full_message="UPS EVENT TYPE $NOTIFYTYPE FROM $UPSNAME ''${NL}''${NL}$1"
        ${(import ../../modules/xmpp-bridge/xmpp-alert.nix {inherit pkgs config inputs system;})}/bin/xmpp-alert echo "$full_message"
      ''}";
      POWERDOWNFLAG = "/run/killpower";
      RUN_AS_USER = "root";
      SHUTDOWNCMD = "${pkgs.systemd}/bin/shutdown now";
      NOTIFYFLAG = [
        ["ONLINE" "SYSLOG+WALL+EXEC"]
        ["ONBATT" "SYSLOG+WALL+EXEC"]
        ["LOWBATT" "SYSLOG+WALL+EXEC"]
        ["FSD" "SYSLOG+WALL+EXEC"]
        ["COMMOK" "SYSLOG+WALL+EXEC"]
        ["COMMBAD" "SYSLOG+WALL+EXEC"]
        ["SHUTDOWN" "SYSLOG+WALL+EXEC"]
        ["REPLBATT" "SYSLOG+WALL+EXEC"]
        ["NOCOMM" "SYSLOG+WALL+EXEC"]
        ["NOPARENT" "SYSLOG+WALL+EXEC"]
        ["CAL" "SYSLOG+WALL+EXEC"]
        ["NOTCAL" "SYSLOG+WALL+EXEC"]
        ["OFF" "SYSLOG+WALL+EXEC"]
        ["NOTOFF" "SYSLOG+WALL+EXEC"]
        ["BYPASS" "SYSLOG+WALL+EXEC"]
        ["NOTBYPASS" "SYSLOG+WALL+EXEC"]
        # Apparently these are invalid notify types?
        # Need to update to 2.8.3+
        # [ "ECO" "SYSLOG+WALL+EXEC" ]
        # [ "NOTECO" "SYSLOG+WALL+EXEC" ]
        # [ "ALARM" "SYSLOG+WALL+EXEC" ]
        # [ "NOTALARM" "SYSLOG+WALL+EXEC" ]
        # [ "OVER" "SYSLOG+WALL+EXEC" ]
        # [ "NOTOVER" "SYSLOG+WALL+EXEC" ]
        # [ "TRIM" "SYSLOG+WALL+EXEC" ]
        # [ "NOTTRIM" "SYSLOG+WALL+EXEC" ]
        # [ "BOOST" "SYSLOG+WALL+EXEC" ]
        # [ "NOTBOOST" "SYSLOG+WALL+EXEC" ]
        # [ "OTHER" "SYSLOG+WALL+EXEC" ]
        # [ "NOTOTHER" "SYSLOG+WALL+EXEC" ]
        # [ "SUSPEND_STARTING" "SYSLOG+WALL+EXEC" ]
        # [ "SUSPEND_FINISHED" "SYSLOG+WALL+EXEC" ]
      ];
    };
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
    restic-environment-storj = {
      file = ../../secrets/restic-environment-storj-ptolemy.age;
    };
    restic-repository-storj = {
      file = ../../secrets/restic-repository-storj-ptolemy.age;
    };
    restic-password-storj = {
      file = ../../secrets/restic-password-storj-ptolemy.age;
    };
    jellyfin-password = {
      file = ../../secrets/jellyfin-ptolemy.age;
      owner = "jellyfin";
      group = "jellyfin";
    };
    samba-password = {
      file = ../../secrets/samba-ptolemy.age;
    };
    paperless = {
      file = ../../secrets/paperless-ptolemy.age;
    };
    wifi-env = {
      file = ../../secrets/wifi-env.age;
    };
  };
}
