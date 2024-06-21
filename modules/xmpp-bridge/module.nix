{ config, pkgs, lib, inputs, system, ... }:
{
  environment.systemPackages = [
    inputs.xmpp-bridge.packages.${system}.default
    (import ./xmpp-alert.nix { inherit pkgs config inputs system; })
  ];
  # Group for access control to xmpp-alert keys
  users.groups."xmpp-alert" = { };
}