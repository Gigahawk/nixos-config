{
  ...
}:
{
  users = {
    users = {
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
      nix-auto-push-recv = { };
    };
  };
}
