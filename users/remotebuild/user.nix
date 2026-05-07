{
  ...
}:
{
  users.users.remotebuild = {
    isSystemUser = true;
    group = "remotebuild";
    useDefaultShell = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFllWhwsgBivFqFcs7djQpb3qbf8EySKMLdGJC2rp0JK virtualbox"
      # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEsuCHOVN9ua62cq+m9C9i9PVrpZaOGiA3NJ0Fhn1kF1 ptolemy"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBexEu5Y3tOU4oe+QXiZWVM/eJcLD3qRjZj1kcsVs4p2 haro"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/c40iufgOIcv8xroyGvyhuVJnlPZpuXUdofu1elpIU veda"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEQmT9/tG95cTnt2wrN+/PlKPiRtFUv11dhtnSyiixVN arios"
    ];
  };

  users.groups.remotebuild = { };

  nix.settings.trusted-users = [ "remotebuild" ];
}
