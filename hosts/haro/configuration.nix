# edit this configuration file to define what should be installed on
# your system.  help is available in the configuration.nix(5) man page
# and in the nixos manual (accessible by running `nixos-help`).

{ config, pkgs, inputs, system, ... }:

{
  imports = [ ];

  # use the systemd-boot efi boot loader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "haro";
  networking.wireless.enable = true;

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
    raspberrypi-eeprom
  ];

  hardware.az-raspi4-base.enable = true;

  #systemd.services.tailscale-autoconnect = {
  #  description = "Automatic connection to Tailscale";

  #  # make sure tailscale is running before trying to connect to tailscale
  #  after = [ "network-pre.target" "tailscale.service" ];
  #  wants = [ "network-pre.target" "tailscale.service" ];
  #  wantedBy = [ "multi-user.target" ];

  #  # set this service as a oneshot job
  #  serviceConfig.Type = "oneshot";

  #  # have the job run this shell script
  #  script = with pkgs; ''
  #    # wait for tailscaled to settle
  #    sleep 2

  #    # check if we are already authenticated to tailscale
  #    status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
  #    if [ $status = "Running" ]; then # if so, then do nothing
  #      exit 0
  #    fi

  #    # otherwise authenticate with tailscale
  #    ${tailscale}/bin/tailscale up --authkey $(cat ${config.age.secrets.tailscale-key.path})
  #  '';
  #};

  #services.netdata = {
  #  enable = true;
  #  config = {
  #    global = {
  #      # uncomment to reduce memory to 32 MB
  #      #"page cache size" = 32;

  #      # update interval
  #      "update every" = 1;
  #    };
  #    web = {
  #      "default port" = 19999;
  #    };
  #    ml = {
  #      # enable machine learning
  #      "enabled" = "yes";
  #    };
  #  };
  #};

  age.secrets = {
    #alert-outlook = {
    #  file = ../../secrets/alert-outlook.age;
    #};
    jasper = {
      file = ../../secrets/jasper-haro.age;
    };
    #tailscale-key = {
    #  file = ../../secrets/tailscale-ptolemy.age;
    #};
    #xmpp-password = {
    #  file = ../../secrets/xmpp-password-ptolemy.age;
    #};
    #xmpp-jid = {
    #  file = ../../secrets/xmpp-jid-ptolemy.age;
    #};
    #xmpp-target-jid = {
    #  file = ../../secrets/xmpp-target-jid.age;
    #};
    wifi-env = {
      file = ../../secrets/wifi-env.age;
    };
  };

}


