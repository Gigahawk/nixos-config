{
  config,
  pkgs,
  lib,
  ...
}:
let
  ports = import ./ports.nix;
in
{
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
}
