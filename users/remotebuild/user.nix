{
  ...
}:
{
  users = {
    users = {
      remotebuild = {
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

      nix-auto-push-recv = {
        isSystemUser = true;
        group = "nix-auto-push-recv";
        # Unfortunately required for nix copy?
        useDefaultShell = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGaNt/NRMNe4wOkoiRAWXWVJL2q0XgurbHNRdcK03Qlr nix-auto-push"
        ];
      };
    };

    groups = {
      remotebuild = { };
      nix-auto-push-recv = { };
    };
  };

  nix = {
    nrBuildUsers = 64;

    settings = {
      trusted-users = [ "remotebuild" ];
    };
  };
}
