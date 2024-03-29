let
  jasper-virtualbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBoOvyE+sGI2jS1owqCXlHpqZcVOSrJwe6QPH5pnTpq";
  jasper-pc-wsl = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIjA/h30yvAJQkkfMBncAKo2aY1dzb+2m/eWw3MLfV76";
  users = [ jasper-pc-wsl jasper-virtualbox ];

  virtualbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeQvEjbv20hcOaJ4RpzrC5eojf1FGG8fN4h9g8vHU/q";
  ptolemy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEsuCHOVN9ua62cq+m9C9i9PVrpZaOGiA3NJ0Fhn1kF1";
  haro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBexEu5Y3tOU4oe+QXiZWVM/eJcLD3qRjZj1kcsVs4p2";
  # For build image host detection
  systems = {
    inherit haro ptolemy virtualbox;
  };
in {
  inherit systems;

  "alert-outlook.age".publicKeys = users ++ [ virtualbox ];

  "jasper-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "samba-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "tailscale-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "xmpp-jid-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "xmpp-password-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "inventree-secret-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "inventree-jasper-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "inventree-backup-pat-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "immich-db-creds-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "restic-environment-storj-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "restic-repository-storj-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "restic-password-storj-virtualbox.age".publicKeys = users ++ [ virtualbox ];

  "jasper-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "tailscale-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "xmpp-jid-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "xmpp-password-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "syncthing-cert-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "syncthing-key-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "immich-db-creds-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "restic-environment-storj-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "restic-repository-storj-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "restic-password-storj-ptolemy.age".publicKeys = users ++ [ ptolemy ];

  "jasper-haro.age".publicKeys = users ++ [ haro ];
  "tailscale-haro.age".publicKeys = users ++ [ ptolemy ];

  "wifi-env.age".publicKeys = users ++ (builtins.attrValues systems);
  "xmpp-target-jid.age".publicKeys = users ++ (builtins.attrValues systems);
}


