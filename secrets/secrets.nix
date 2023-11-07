let
  jasper-virtualbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBoOvyE+sGI2jS1owqCXlHpqZcVOSrJwe6QPH5pnTpq";
  jasper-pc-wsl = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIjA/h30yvAJQkkfMBncAKo2aY1dzb+2m/eWw3MLfV76";
  users = [ jasper-pc-wsl jasper-virtualbox ];

  virtualbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeQvEjbv20hcOaJ4RpzrC5eojf1FGG8fN4h9g8vHU/q";
  systems = [ virtualbox ];
in {
  "alert-outlook.age".publicKeys = users ++ systems;
  "jasper-virtualbox.age".publicKeys = users ++ systems;
  "samba-virtualbox.age".publicKeys = users ++ systems;
  "tailscale-virtualbox.age".publicKeys = users ++ systems;
}


