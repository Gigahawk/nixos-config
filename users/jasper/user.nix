{ config, pkgs, ... }:

{
  users.users.jasper = {
    isNormalUser = true;
    passwordFile = config.age.secrets.jasper.path;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };
}


