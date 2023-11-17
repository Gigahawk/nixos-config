{ config, pkgs, ... }:
let
  notifyScript = pkgs.writeScript "smartd-notify.sh" ''
    #! ${pkgs.runtimeShell}
    xmpp-alert echo -e \
    "Problem detected with disk: $SMARTD_DEVICESTRING\n" \
    "Warning message from smartd is:\n\n" \
    "$SMARTD_FULLMESSAGE"
  '';
in
{
  services.smartd = {
    enable = true;
    autodetect = true;
    notifications = {
      x11.enable = false;
      wall.enable = false;
      mail.enable = false;
    };
    defaults.autodetected = "-a -o on -s (S/../.././02|L/../../7/04) -m <nomailer> -M exec ${notifyScript} -M test";
  };
}


