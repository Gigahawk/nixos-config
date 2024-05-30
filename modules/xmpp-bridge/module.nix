{ config, pkgs, lib, inputs, system, ... }:
{
  environment.systemPackages = [
    inputs.xmpp-bridge.packages.${system}.default
    (import ./xmpp-alert.nix { inherit pkgs config inputs system; })
  ];
}