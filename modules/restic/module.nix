{ lib, pkgs, config, inputs, system, ... }:
{
  services.restic.backups.storj = {
    initialize = true;
    environmentFile = config.age.secrets.restic-environment-storj.path;
    repositoryFile = config.age.secrets.restic-repository-storj.path;
    passwordFile = config.age.secrets.restic-password-storj.path;
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 2"
      "--keep-yearly 0"
    ];
    paths = [
      "/mnt/pool"
    ];
    extraBackupArgs = [
      "--exclude-caches"
    ];

    timerConfig = {
      OnCalendar = "*-*-* 01:00:00";
      # Trigger immediately if we missed the last time
      Persistent = true;
    };
  };

  # TODO: is there a way to improve code reuse here?
  systemd.services.restic-backups-storj.unitConfig.OnSuccess = "notify-backup-success.service";
  systemd.services."notify-backup-success" = {
    enable = true;
    description = "Notify restic backup was successful";
    serviceConfig.Type = "oneshot";
    path = [
      inputs.xmpp-bridge.packages.${system}.default
      (import ../xmpp-bridge/xmpp-alert.nix { inherit pkgs config; })
    ];
    script = ''
      xmpp-alert echo "RESTIC BACKUP LOGS (PASS)"
      xmpp-alert journalctl _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value restic-backups-storj.service`
      xmpp-alert echo "RESTIC BACKUP PASSED"
    '';
  };

  systemd.services.restic-backups-storj.unitConfig.OnFailure = "notify-backup-failure.service";
  systemd.services."notify-backup-failure" = {
    enable = true;
    description = "Notify restic backup failure";
    serviceConfig.Type = "oneshot";
    path = [
      inputs.xmpp-bridge.packages.${system}.default
      (import ../xmpp-bridge/xmpp-alert.nix { inherit pkgs config; })
    ];
    script = ''
      xmpp-alert echo "RESTIC BACKUP LOGS (FAIL)"
      xmpp-alert journalctl _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value restic-backups-storj.service`
      xmpp-alert echo "RESTIC BACKUP FAILED"
    '';
  };
}