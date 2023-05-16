{ config, pkgs, ... }:

{
  users.users.jasper = {
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };
}


