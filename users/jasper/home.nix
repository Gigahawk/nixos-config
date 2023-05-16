{ config, pkgs, ... }:

{
  home.username = "jasper";
  home.homeDirectory = "/home/jasper";

  programs.home-manager.enable = true;
  
}

