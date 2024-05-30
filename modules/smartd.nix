{ config, pkgs, inputs, system, ... }:
let
  xmpp-alert = (import ./xmpp-bridge/xmpp-alert.nix { inherit pkgs config inputs system; });
  notifyScript = pkgs.writeScript "smartd-notify.sh" ''
    #! ${pkgs.runtimeShell}
    ${xmpp-alert}/bin/xmpp-alert ${pkgs.coreutils}/bin/cat << EOF
    Problem detected with disk: $SMARTD_DEVICESTRING
    Warning message from smartd is:

    $SMARTD_FULLMESSAGE
    EOF
  '';
in
{
  # TODO: do we need this?
  systemd.tmpfiles.rules = [
    "d /var/log/smartd 0777 root root"
  ];
  services.smartd = {
    enable = true;
    extraOptions = [
      "-A /var/log/smartd/"
    ];
    autodetect = true;
    notifications = {
      x11.enable = false;
      wall.enable = false;
      mail.enable = false;
    };
    defaults.autodetected = "-a -o on -s (S/../.././02|L/../../7/04) -m <nomailer> -M exec ${notifyScript} -M test";
  };
}


