{
  config,
  pkgs,
  lib,
  inputs,
  stdenv,
  ...
}:

{
  environment.systemPackages = [
    inputs.agenix.packages."${stdenv.hostPlatform.system}".default
  ];
}
