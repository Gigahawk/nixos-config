{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  ports = import ./ports.nix;
in
{
  imports = [
    inputs.nix-auto-push.nixosModules.default
  ];

  nix = lib.mkIf (config.networking.hostName != "ptolemy") {
    distributedBuilds = true;
    settings = {
      builders-use-substitutes = true;
      substituters = [
        # Default nixpkgs cache has a priority of 40 (lower value is queried first)
        # Use default nixpkgs cache where possible
        "http://ptolemy.neon-chameleon.ts.net:${toString ports.nix-serve-external}?priority=50"
      ];
    };
    buildMachines = [
      {
        hostName = "ptolemy";
        sshUser = "remotebuild";
        sshKey = "/etc/ssh/ssh_host_ed25519_key";
        inherit (pkgs.stdenv.hostPlatform) system;
        supportedFeatures = [
          "nixos-test"
          "kvm"
          "nixos-test"
          "benchmark"
          "big-parallel"
        ];

        maxJobs = 6;
        speedFactor = 10;
      }
    ];
  };

  services.nix-auto-push = lib.mkIf (config.networking.hostName != "ptolemy") {
    enable = true;
    target = "ptolemy";
    targetUser = "nix-auto-push-recv";
    retryAttempts = 2;
    sshOpts = [
      "-oStrictHostKeyChecking=accept-new"
      "-i ${config.age.secrets.nix-auto-push-private-key.path}"
    ];
  };

  age.secrets = lib.mkIf (config.networking.hostName != "ptolemy") {
    nix-auto-push-private-key = {
      file = ./secrets/nix-auto-push-private-key.age;
      owner = config.services.nix-auto-push.serviceUser;
      group = config.services.nix-auto-push.serviceUser;
    };
  };
}
