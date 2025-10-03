# edit this configuration file to define what should be installed on
# your system.  help is available in the configuration.nix(5) man page
# and in the nixos manual (accessible by running `nixos-help`).

{ config, lib, pkgs, inputs, system, ... }:

{
  imports = [ ];

  # use the systemd-boot efi boot loader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "haro";
  networking.firewall.allowedTCPPorts = [
    80
  ];

  # This is a server, disable sleep
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

  services.kvmd = {
    enable = true;
    allowMmap = true;
    baseConfig = "v3-hdmi-rpi4.yaml";
    udevRules = "v2-hdmi-rpi4.rules";
    fanConfig = "v3-hdmi.ini";
    # HACK: BliKVM PCIe fan doesn't seem to start until pwm=820 for some reason
    # TODO: figure out if this pwm range even results in different RPM
    fanArgs = "--debug --pwm-low=819 --pwm-high=1024";
    edidConfig = "v4mini.hex";
    htPasswordFile = config.age.secrets.kvmd-htpasswd.path;
    totpSecretFile = config.age.secrets.kvmd-totp-secret.path;
    vncSslKeyFile = config.age.secrets.kvmd-vnc-key.path;
    vncSslCertFile = config.age.secrets.kvmd-vnc-cert.path;
    createMsdImage = true;
    msdImageSize = "64G";
    enableOled = true;
    overrides = {
      kvmd = {
        hid = {
          mouse_alt = {
            device = "/dev/kvmd-hid-mouse-alt";
          };
        };
        gpio = {
          scheme = {
            __v3_usb_breaker__ = {
              pulse = {
                delay = 0;
              };
            };
          };
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    raspberrypi-eeprom
    libraspberrypi
    (callPackage ../../packages/vcgencmd_nice.nix {})
  ];

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
    tailscale-key = {
      file = ../../secrets/tailscale-haro.age;
    };
    #xmpp-password = {
    #  file = ../../secrets/xmpp-password-ptolemy.age;
    #};
    #xmpp-jid = {
    #  file = ../../secrets/xmpp-jid-ptolemy.age;
    #};
    #xmpp-target-jid = {
    #  file = ../../secrets/xmpp-target-jid.age;
    #};
    kvmd-ipmipasswd = {
      file = ../../secrets/kvmd-ipmipasswd-haro.age;
      owner = "kvmd";
      group = "kvmd";
    };
    kvmd-htpasswd = {
      file = ../../secrets/kvmd-htpasswd-haro.age;
      owner = "kvmd";
      group = "kvmd";
    };
    kvmd-totp-secret = {
      file = ../../secrets/kvmd-totp-secret-haro.age;
      owner = "kvmd";
      group = "kvmd";
    };
    kvmd-vncpasswd = {
      file = ../../secrets/kvmd-vncpasswd-haro.age;
      owner = "kvmd";
      group = "kvmd";
    };
    kvmd-vnc-key = {
      file = ../../secrets/kvmd-vnc-key-haro.age;
      owner = "kvmd";
      group = "kvmd";
    };
    kvmd-vnc-cert = {
      file = ../../secrets/kvmd-vnc-cert-haro.age;
      owner = "kvmd";
      group = "kvmd";
    };
    wifi-env = {
      file = ../../secrets/wifi-env.age;
    };
  };

}


