# edit this configuration file to define what should be installed on
# your system.  help is available in the configuration.nix(5) man page
# and in the nixos manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports = [ ];

  # use the systemd-boot efi boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "virtualbox";

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

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
  };

}


