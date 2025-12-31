{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  environment.systemPackages = [
    inputs.smartp.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  systemd.services.run_smartp = {
    serviceConfig.Type = "oneshot";
    serviceConfig.RestartSec = 30;
    serviceConfig.Restart = "on-failure";
    startLimitIntervalSec = 300;
    startLimitBurst = 5;
    path = [
      pkgs.util-linux
      inputs.xmpp-bridge.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.smartp.packages.${pkgs.stdenv.hostPlatform.system}.default
      (import ../xmpp-bridge/xmpp-alert.nix {
        inherit
          pkgs
          config
          inputs
          ;
      })
    ];
    script = builtins.readFile ./run_smartp.sh;
  };
  systemd.timers.run_smartp = {
    wantedBy = [ "timers.target" ];
    partOf = [ "run_smartp.service" ];
    # Run every day except for first of the month
    timerConfig.OnCalendar = [ "*-*-02..31 12:00:00" ];
  };

  systemd.services.run_smartp_long = {
    serviceConfig.Type = "oneshot";
    path = [
      pkgs.util-linux
      inputs.xmpp-bridge.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.smartp.packages.${pkgs.stdenv.hostPlatform.system}.default
      (import ../xmpp-bridge/xmpp-alert.nix {
        inherit
          pkgs
          config
          inputs
          ;
      })
    ];
    script = builtins.readFile ./run_smartp_long.sh;
  };
  systemd.timers.run_smartp_long = {
    wantedBy = [ "timers.target" ];
    partOf = [ "run_smartp_long.service" ];
    # Run every first of the month
    timerConfig.OnCalendar = [ "*-*-1 12:00:00" ];
  };
}
