{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.services.samba-users;
  usersFile = pkgs.writeText "users.json" (builtins.toJSON cfg.users);
  settingsFormat = pkgs.formats.json { };
in
{
  options.services.samba-users = {
    enable = mkEnableOption (lib.mdDoc "Setup samba users");

    users = mkOption {
      default = { };
      description = mdDoc ''
        Users which should be present on the samba server
      '';

      example = {
        admin = {
          password_file = /path/to/passwordfile;
        };
      };

      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            freeformType = settingsFormat.type;
            options = {
              name = mkOption {
                type = types.str;
                default = name;
                description = lib.mdDoc ''
                  The name of the user (must match a linux user on the system)
                '';
              };

              password_file = mkOption {
                type = types.path;
                description = lib.mdDoc ''
                  The path to the password file for the user
                '';
              };
            };
          }
        )
      );
    };
  };

  config = mkIf cfg.enable {
    systemd.services.samba-users = {
      description = "Samba SMB user creation service";

      wantedBy = [ "multi-user.target" ];
      before = [ "samba.target" ];

      serviceConfig = {
        User = "root";
        Group = "root";
        ExecStartPre = "+${pkgs.writers.writeBash "samba-users" ''
          echo "Deleting existing samba users"

          old_users=$(${pkgs.samba4Full}/bin/pdbedit -L)
          while IFS= read -r line; do
            username=$(echo "$line" | cut -d: -f1)
            if [[ -z "$username" ]]; then
              continue
            fi
            echo "Deleting samba user $username"
            ${pkgs.samba4Full}/bin/smbpasswd -x "$username"
          done <<<"$old_users"


          echo "Creating new users"

          new_users=$(${pkgs.jq}/bin/jq -r 'keys[]' ${usersFile})
          while IFS= read -r username; do
            password_file=$(${pkgs.jq}/bin/jq -r ".$username.password_file" ${usersFile})
            password=$(cat "$password_file")
            # smbpasswd expects password twice
            password_input=$(printf "$password\n$password")

            if [[ -z "$username" ]]; then
              continue
            fi
            echo "Creating user $username from password file $password_file"
            echo "$password_input" | ${pkgs.samba4Full}/bin/smbpasswd -s -a "$username"
          done <<<"$new_users"
        ''}";

        ExecStart = ''
          ${pkgs.coreutils}/bin/true
        '';
      };
    };
  };
}
