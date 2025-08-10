let
  jasper-virtualbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBoOvyE+sGI2jS1owqCXlHpqZcVOSrJwe6QPH5pnTpq";
  jasper-pc-wsl = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIjA/h30yvAJQkkfMBncAKo2aY1dzb+2m/eWw3MLfV76";
  jasper-veda = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFuW7/do+fI6PCEQdb+Ui0zBPlZvo/YKf5Nl6uujoPl2";
  users = [ jasper-pc-wsl jasper-virtualbox jasper-veda ];

  virtualbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFllWhwsgBivFqFcs7djQpb3qbf8EySKMLdGJC2rp0JK";
  ptolemy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEsuCHOVN9ua62cq+m9C9i9PVrpZaOGiA3NJ0Fhn1kF1";
  haro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBexEu5Y3tOU4oe+QXiZWVM/eJcLD3qRjZj1kcsVs4p2";
  veda = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/c40iufgOIcv8xroyGvyhuVJnlPZpuXUdofu1elpIU";
  arios = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEQmT9/tG95cTnt2wrN+/PlKPiRtFUv11dhtnSyiixVN";
  # For build image host detection
  systems = {
    inherit haro ptolemy virtualbox veda arios;
  };
in {
  #inherit systems;

  "alert-outlook.age".publicKeys = users ++ [ virtualbox ];

  "jasper-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "samba-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "tailscale-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "xmpp-jid-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "xmpp-password-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "inventree-secret-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "inventree-jasper-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "inventree-backup-pat-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "restic-environment-storj-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "restic-repository-storj-virtualbox.age".publicKeys = users ++ [ virtualbox ];
  "restic-password-storj-virtualbox.age".publicKeys = users ++ [ virtualbox ];

  "jasper-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "tailscale-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "xmpp-jid-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "xmpp-password-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "syncthing-cert-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "syncthing-key-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "inventree-secret-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "inventree-jasper-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "inventree-backup-pat-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "restic-environment-storj-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "restic-repository-storj-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "restic-password-storj-ptolemy.age".publicKeys = users ++ [ ptolemy ];
  "upsmon-ptolemy.age".publicKeys = users ++ [ ptolemy ];

  "jasper-haro.age".publicKeys = users ++ [ haro ];
  "kvmd-ipmipasswd-haro.age".publicKeys = users ++ [ haro ];
  "kvmd-htpasswd-haro.age".publicKeys = users ++ [ haro ];
  "kvmd-totp-secret-haro.age".publicKeys = users ++ [ haro ];
  "kvmd-vncpasswd-haro.age".publicKeys = users ++ [ haro ];
  "kvmd-vnc-key-haro.age".publicKeys = users ++ [ haro ];
  "kvmd-vnc-cert-haro.age".publicKeys = users ++ [ haro ];
  "tailscale-haro.age".publicKeys = users ++ [ haro ];

  "jasper-veda.age".publicKeys = users ++ [ veda ];

  "jasper-arios.age".publicKeys = users ++ [ arios ];
  "tailscale-arios.age".publicKeys = users ++ [ arios ];
  "syncthing-cert-arios.age".publicKeys = users ++ [ arios ];
  "syncthing-key-arios.age".publicKeys = users ++ [ arios ];

  "wifi-env.age".publicKeys = users ++ (builtins.attrValues systems);
  "xmpp-target-jid.age".publicKeys = users ++ (builtins.attrValues systems);
}


