{ config, pkgs, inputs, ... }:

{
  imports = [ ];

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  networking.wireless.enable = false;
  networking.networkmanager.enable = true;
  boot = {
    extraModulePackages = [
      config.boot.kernelPackages.broadcom_sta
    ];
    kernelModules = [ "wl" ];
    initrd.kernelModules = [ "kvm-intel" "wl" ];
  };
}


