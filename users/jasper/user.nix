{ config, pkgs, ... }:

{
  users.users.jasper = {
    isNormalUser = true;
    passwordFile = config.age.secrets.jasper.path;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIjA/h30yvAJQkkfMBncAKo2aY1dzb+2m/eWw3MLfV76 jasper"
    ];
  };
}


