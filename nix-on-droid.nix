{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./packages-all.nix
    ./modules/nix-on-droid/module.nix
  ];
  nix.nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
  ];
  system.stateVersion = "24.05";
}
