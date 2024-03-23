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

  virtualisation.oci-containers.backend = "docker";

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

  services.immich = {
    enable = true;
    dataPath = "/mnt/pool/immich";
    dbPath = "/mnt/pool/immich/data";
    dbCredentialsFile = config.age.secrets.immich-db-creds.path;
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
    xmpp-password = {
      file = ../../secrets/xmpp-password-ptolemy.age;
    };
    xmpp-jid = {
      file = ../../secrets/xmpp-jid-ptolemy.age;
    };
    xmpp-target-jid = {
      file = ../../secrets/xmpp-target-jid.age;
    };
    immich-db-creds = {
      file = ../../secrets/immich-db-creds-ptolemy.age;
    };
    wifi-env = {
      file = ../../secrets/wifi-env.age;
    };
  };

}


