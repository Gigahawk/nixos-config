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
    };
  };

  age.secrets = {
    alert-gmail = {
      file = ../../secrets/alert-gmail.age;
      path = "/etc/alert-gmail";
    };
  };

}


