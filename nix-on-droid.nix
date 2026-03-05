{
  pkgs,
  ...
}:
{
  imports = [
    ./packages-all.nix
    ./modules/nix-on-droid/module.nix
  ];
  system.stateVersion = "24.05";
}
