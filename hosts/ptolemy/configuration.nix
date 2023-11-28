# edit this configuration file to define what should be installed on
# your system.  help is available in the configuration.nix(5) man page
# and in the nixos manual (accessible by running `nixos-help`).

{ config, pkgs, inputs, system, ... }:

{
  imports = [ ];

  #virtualisation.arion = {
  #  backend = "docker";
  #  projects =
  #  {
  #    inventree.settings = {
  #      imports = [./../../docker-compose/inventree/arion-compose.nix];
  #    };
  #  };
  #};

  # use the systemd-boot efi boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ptolemy";

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # This is a server, disable sleep
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

  systemd.services.snapraid_sync = {
    serviceConfig.Type = "oneshot";
    serviceConfig.RestartSec = 30;
    serviceConfig.Restart = "on-failure";
    startLimitIntervalSec = 300;
    startLimitBurst = 5;
    path = [
      inputs.xmpp-bridge.packages.${system}.default
      (import ../../modules/xmpp-alert.nix { inherit pkgs config; })
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

  services.syncthing = {
    enable = true;
    dataDir = "/home/jasper";
    openDefaultPorts = true;
    configDir = "/etc/syncthing";
    user = "jasper";
    group = "users";
    guiAddress = "0.0.0.0:8384";
    key = config.age.secrets.syncthing-key.path;
    cert = config.age.secrets.syncthing-cert.path;
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      devices = {
        JASPER-PC = {  # Windows
          id = "F424O47-RWTQQSG-L7TZ7CP-OM77COG-QVB4WZW-XVOA2DU-5CJPTYQ-KKYHHQQ";
        };
        jasper-void = {  # Void Linux
          id = "2M3W4TM-4BJQSNJ-BTUNFTU-PJ4TK7E-B7C37VA-BMOSV7X-UFHVNJE-UDBPQQ7";
        };
        ptolemy = {
          id = "DVSWOT3-6RE3PRD-OB3IVQI-VELDUFR-EMHZZCR-MPGNVW3-EIHW4LK-REFXVAJ";
        };
        remarkable = {  # reMarkable
          id = "Q5JA76T-C53YAWX-G4LI7R2-2BI445S-VPVDTS3-ZUGGV56-YGO6ZXD-LY3JAQI";
        };
        zenfone-9 = {  # Android
          id = "ELDFXOS-ACVLSIP-X53SGCS-MW6OC6X-B6PZVJN-X5ZTT6V-QHEIPLF-AQDTGAP";
        };
      };
      folders = {
        Music = {
          id = "Music";
          path = "/mnt/pool/Music";
          devices = [
            "JASPER-PC"
            "jasper-void"
            "ptolemy"
            "zenfone-9"
          ];
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600"; # 1 hour in seconds
              maxAge = "15552000"; # 180 days in seconds
            };
          };
        };
        Documents = {
          id = "Documents";
          path = "/mnt/pool/Documents";
          devices = [
            "JASPER-PC"
            "jasper-void"
            "ptolemy"
            "zenfone-9"
          ];
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600"; # 1 hour in seconds
              maxAge = "15552000"; # 180 days in seconds
            };
          };
        };
        Homework = {
          id = "Homework";
          path = "/mnt/pool/Homework";
          devices = [
            "JASPER-PC"
            "jasper-void"
            "ptolemy"
          ];
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600"; # 1 hour in seconds
              maxAge = "15552000"; # 180 days in seconds
            };
          };
        };
        remarkable_sync = {
          type = "recieveonly";
          id = "remarkable_sync";
          path = "/mnt/pool/remarkable_sync";
          devices = [
            "JASPER-PC"
            "jasper-void"
            "ptolemy"
            "remarkable"
            "zenfone-9"
          ];
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600"; # 1 hour in seconds
              maxAge = "15552000"; # 180 days in seconds
            };
          };
        };
      };
      options = {
        urAccepted = 3;  # Allow usage reporting
      };
      gui = {
        user = "jasper";
        # ENSURE YOU USE A BCRYPT ENCRYPTED PASSWORD
        password = "$2a$10$mPe007buYdatkjXt9w71cu8XBuBACsAHgQ0oLEfacIqUeNOt6Dok6";
      };
    };
  };

  snapraid = {
    enable = true;
    dataDisks = {
      d0 = "/mnt/data0";
      d1 = "/mnt/data1";
      # d2 = "/mnt/data2";
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
      # "/mnt/data2/snapraid.content"
    ];
    exclude = [
      "/lost+found/"
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
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = Samba %v on (%h)
      server role = standalone server

      # idk if this needs to be set
      # netbios name = ptolemy

      # isn't this set by securityType?
      # security = user

      # idk disabled in the example
      # use sendfile = yes
      # max protocol = smb2

      hosts allow = 0.0.0.0/0
      # hosts allow = 192.168.1. 192.168.0. 192.168.56. 127.0.0.1 localhost
      # hosts deny = 0.0.0.0/0

      # guest account = jasper
      # map to guest = bad user
    '';
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
    };
  };

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up --authkey $(cat ${config.age.secrets.tailscale-key.path})
    '';
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
    xmpp-password = {
      file = ../../secrets/xmpp-password-ptolemy.age;
    };
    xmpp-jid = {
      file = ../../secrets/xmpp-jid-ptolemy.age;
    };
    xmpp-target-jid = {
      file = ../../secrets/xmpp-target-jid.age;
    };
  };

}


