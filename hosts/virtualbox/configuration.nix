# edit this configuration file to define what should be installed on
# your system.  help is available in the configuration.nix(5) man page
# and in the nixos manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports = [ ];

  virtualisation.arion = {
    backend = "docker";
    projects = 
    {
      inventree.settings = {
        imports = [./../../docker-compose/inventree/arion-compose.nix];
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

      hosts allow = 192.168.1. 192.168.0. 192.168.56. 127.0.0.1 localhost
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
      ${tailscale}/bin/tailscale up --authkey $(cat ${config.age.secrets.tailscale-virtualbox.path})
    '';
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
    tailscale-virtualbox = {
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
  };

}


