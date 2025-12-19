{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  environment.systemPackages = [
    inputs.agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];
}
