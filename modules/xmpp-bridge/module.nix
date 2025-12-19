{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  environment.systemPackages = [
    inputs.xmpp-bridge.packages.${stdenv.hostPlatform.system}.default
    (import ./xmpp-alert.nix {
      inherit
        pkgs
        config
        inputs
        ;
    })
  ];
  # Group for access control to xmpp-alert keys
  users.groups."xmpp-alert" = { };
}
