{ lib, pkgs, config, inputs, system, ... }:
with lib;
let
  cfg = config.snapraidSettings;
  # What does this do?
  settingsFormat = pkgs.formats.json { };
in
{
  options.snapraidSettings = {
    dataDisks = mkOption {
      description = mdDoc ''
        Attr set of disks to sync
      '';
      type = types.attrsOf types.str;
      default = {};
    };
    parityFiles = mkOption {
      description = mdDoc ''
        List of files to store parity data in
      '';
      type = types.listOf types.str;
      default = [];
    };
    exclude = mkOption {
      description = mdDoc ''
        List of paths to exclude from sync
      '';
      type = types.listOf types.str;
      default = [ "/lost+found/" ];
    };
  };

  config = {
    services.snapraid = {
      enable = true;
      # disable maintenance services, handle using our own service
      sync.interval = "1970-01-01";
      scrub.interval = "1970-01-01";

      dataDisks = cfg.dataDisks;
      parityFiles = cfg.parityFiles;
      exclude = cfg.exclude;
      # Put a content file on every data disk
      contentFiles = [ "/var/snapraid.content" ] ++ lib.mapAttrsToList
        (name: path: "${path}/snapraid.content")
        cfg.dataDisks;
    };

    systemd.services.snapraid_sync = {
      serviceConfig.Type = "oneshot";
      serviceConfig.RestartSec = 30;
      serviceConfig.Restart = "on-failure";
      startLimitIntervalSec = 300;
      startLimitBurst = 5;
      path = [
        inputs.xmpp-bridge.packages.${system}.default
        (import ../xmpp-bridge/xmpp-alert.nix { inherit pkgs config; })
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
  };
}


