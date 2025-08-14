{
  config,
  pkgs,
  ...
}: {
  users.users.jasper = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.jasper.path;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      # JASPER-PC Ubuntu WSL
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIjA/h30yvAJQkkfMBncAKo2aY1dzb+2m/eWw3MLfV76 jasper"
      # veda
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFuW7/do+fI6PCEQdb+Ui0zBPlZvo/YKf5Nl6uujoPl2 jasper"
      # virtualbox
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBoOvyE+sGI2jS1owqCXlHpqZcVOSrJwe6QPH5pnTpq jasper"
    ];
  };
}
