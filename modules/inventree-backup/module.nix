{ lib, pkgs, config, options, system, inputs, ... }:
with lib;
let
  ivCfg = config.services.inventree;
  cfg = config.services.inventreeBackup;
  settingsFormat = pkgs.formats.json { };
  defaultUser = "inventree";
  defaultGroup = defaultUser;
  configFile = pkgs.writeText "config.yaml" (builtins.toJSON cfg.config);
  usersFile = pkgs.writeText "users.json" (builtins.toJSON cfg.users);
in
{
  options.services.inventreeBackup = {
    enable = mkEnableOption
      (lib.mdDoc "Routine backups for the local InvenTree install");

    interval = mkOption {
      type = types.str;
      default = "*-*-* 04:00:00";
      description = lib.mdDoc ''
        Systemd OnCalendar value for when to run a backup
      '';
    };

    backupPath = mkOption {
      type = types.str;
      description = lib.mdDoc ''
        Path to backup location
      '';
    };

    enablePush = mkEnableOption
      (lib.mdDoc "Enable pushing backups to a remote github repo");
    pushRemote = mkOption {
      type = types.str;
      example = "Gigahawk/inventree-backup";
      description = lib.mdDoc ''
        Github owner/repo name to push backups to
      '';
    };
    patFile = mkOption {
      type = types.path;
      description  = lib.mdDoc ''
        Path to a file containing the Github PAT to access the repo
      '';
    };
  };

  config = mkIf cfg.enable ({

    systemd.services.inventree-backup = {
      description = "InvenTree backup service";
      environment = {
        INVENTREE_CONFIG_FILE = toString ivCfg.configPath;
      };
      startLimitIntervalSec = 300;
      startLimitBurst = 5;
      path = [
        inputs.xmpp-bridge.packages.${system}.default
        (import ../xmpp-bridge/xmpp-alert.nix { inherit pkgs config inputs system; })
        inputs.inventree.packages.${system}.invoke
        pkgs.git
      ];
      serviceConfig = {
        Type = "oneshot";
        RestartSec = 60;
        Restart = "on-failure";
        User = defaultUser;
        Group = defaultGroup;
        ExecStart =
          "+${pkgs.writers.writeBash "inventree-backup" ''
            xmpp-alert echo "Starting InvenTree backup"

            xmpp-alert echo "Ensuring backup dir exists"
            mkdir -p ${cfg.backupPath}
            cd ${cfg.backupPath}

            xmpp-alert echo "Initializing git repo"
            xmpp-alert git init
            xmpp-alert git branch -m master
            xmpp-alert git config user.email "inventree-backup@$(hostname)"
            xmpp-alert git config user.name "inventree-backup"

            xmpp-alert echo "Running database backup"
            xmpp-alert rm data.json*
            xmpp-alert inventree-invoke export-records -f "$(pwd)/data.json"
            xmpp-alert rm *.tmp
            xmpp-alert git add data.json

            xmpp-alert echo "Running media backup"
            xmpp-alert rm -rf media
            xmpp-alert cp -r ${ivCfg.config.media_root} ./media
            xmpp-alert git add media

            xmpp-alert echo "Comitting backup"
            xmpp-alert git commit -m "\"Backup at $(date)\""

            xmpp-alert echo "InvenTree backup complete"
          ''}";
        ExecStartPost = mkIf cfg.enablePush (
          "+${pkgs.writers.writeBash "inventree-backup-push" ''
            cd ${cfg.backupPath}
            xmpp-alert echo "Pushing InvenTree backups"
            xmpp-alert git push \
              https://$(cat ${cfg.patFile})@github.com/${cfg.pushRemote}.git "master:backup-$(date +%s)"
            xmpp-alert git push \
              https://$(cat ${cfg.patFile})@github.com/${cfg.pushRemote}.git "master:master"
            xmpp-alert echo "Push complete"
          ''}"
        );

      };
    };
    systemd.timers.inventree-backup = {
      wantedBy = [ "timers.target" ];
      partOf = [ "inventree-backup.service" ];
      # TODO: Change this to once a week or something
      timerConfig.OnCalendar = [ cfg.interval ];
    };
  });
}