{
  config,
  pkgs,
  inputs,
  system,
  ...
}:
{
  systemd.services.startup-notify = {
    description = "Report successful bootup";

    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [
      inputs.xmpp-bridge.packages.${system}.default
      (import ../xmpp-bridge/xmpp-alert.nix {
        inherit
          pkgs
          config
          inputs
          system
          ;
      })
      pkgs.hostname
    ];
    serviceConfig = {
      Type = "oneshot";
      RestartSec = 5;
      Restart = "on-failure";
      SupplementaryGroups = "xmpp-alert";
    };

    script = ''
      xmpp-alert echo "$(hostname) has booted up"
    '';
  };

  # Kinda hacky, based on https://unix.stackexchange.com/questions/739363/a-systemd-service-that-runs-just-before-shutdown-and-uses-a-mounted-filesystem
  # Not sure why I cant just use before reboot.target or something
  systemd.services.shutdown-notify = {
    description = "Report imminent shutdown";

    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [
      inputs.xmpp-bridge.packages.${system}.default
      (import ../xmpp-bridge/xmpp-alert.nix {
        inherit
          pkgs
          config
          inputs
          system
          ;
      })
      pkgs.hostname
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SupplementaryGroups = "xmpp-alert";
      ExecStart = "${pkgs.coreutils}/bin/true";
      ExecStop = "${pkgs.writers.writeBash "shutdown-notify" ''
        xmpp-alert echo "$(hostname) is shutting down"
      ''}";
    };

  };
}
