{ config, pkgs, ... }:

{
  imports = [ ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    xplr
  ];

  system.stateVersion = "23.05";

}


