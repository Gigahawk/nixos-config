{ config, pkgs, ... }:

{
  imports = [ ];

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;
}


