let
  jasper-virtualbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBoOvyE+sGI2jS1owqCXlHpqZcVOSrJwe6QPH5pnTpq";
  users = [ jasper-virtualbox ];

  virtualbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeQvEjbv20hcOaJ4RpzrC5eojf1FGG8fN4h9g8vHU/q";
  systems = [ virtualbox ];
in {
  "alert-outlook.age".publicKeys = [ jasper-virtualbox virtualbox ];
  "jasper-virtualbox.age".publicKeys = [ jasper-virtualbox virtualbox ];
  "samba-virtualbox.age".publicKeys = [ jasper-virtualbox virtualbox ];
}


