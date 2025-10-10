{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.syncthingSettings;
  # What does this do?
  settingsFormat = pkgs.formats.json { };
in
{
  options.syncthingSettings = {
    guiPassword = mkOption {
      type = types.str;
      description = mdDoc ''
        
                Password to the web GUI
                ENSURE THIS IS A BCRYPT ENCRYPTED PASSWORD
      '';
    };
    folders = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            freeformType = settingsFormat.type;
            options = {
              name = mkOption {
                type = types.str;
                default = name;
                description = mdDoc ''
                  
                                The name of the folder as specified in `modules/syncthing.nix`
                '';
              };
              path = mkOption {
                type = types.str;
                description = mdDoc ''
                  
                                The path to keep the folder
                '';
              };
            };
          }
        )
      );
    };
  };

  config = {
    services.syncthing = {
      enable = true;
      dataDir = "/home/jasper";
      openDefaultPorts = true;
      configDir = "/etc/syncthing";
      user = "jasper";
      group = "users";
      guiAddress = "0.0.0.0:8384";
      key = config.age.secrets.syncthing-key.path;
      cert = config.age.secrets.syncthing-cert.path;
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices = {
          JASPER-PC = {
            # Windows
            id = "F424O47-RWTQQSG-L7TZ7CP-OM77COG-QVB4WZW-XVOA2DU-5CJPTYQ-KKYHHQQ";
          };
          jasper-void = {
            # Void Linux
            id = "2M3W4TM-4BJQSNJ-BTUNFTU-PJ4TK7E-B7C37VA-BMOSV7X-UFHVNJE-UDBPQQ7";
          };
          ptolemy = {
            id = "DVSWOT3-6RE3PRD-OB3IVQI-VELDUFR-EMHZZCR-MPGNVW3-EIHW4LK-REFXVAJ";
          };
          arios = {
            id = "53W7CGR-T26ZSLR-24VDJKE-VTZZVTJ-PP64OGV-SMXMQOS-CABLEOT-ZCBPJQM";
          };
          remarkable = {
            # reMarkable
            id = "UVYGJP5-OUFMTDJ-KFGK7I2-TR4NTSS-CFH7CDS-RFIKZE3-OLCJQ4Q-KURM3QR";
          };
          zenfone-9 = {
            # Android
            id = "ELDFXOS-ACVLSIP-X53SGCS-MW6OC6X-B6PZVJN-X5ZTT6V-QHEIPLF-AQDTGAP";
          };
          xperia-1-vii = {
            # Android
            id = "RFVEXCD-DJU6OEU-N23RCRA-NYNDR2P-6DRCAUB-GBPBALG-WHMQSRK-3HIONQK";
          };
        };
        folders = {
          Music = mkIf (builtins.hasAttr "Music" cfg.folders) {
            id = "Music";
            path = cfg.folders.Music.path;
            devices = [
              "JASPER-PC"
              "jasper-void"
              "ptolemy"
              "zenfone-9"
              "xperia-1-vii"
            ];
            versioning = {
              type = "staggered";
              params = {
                cleanInterval = "3600"; # 1 hour in seconds
                maxAge = "15552000"; # 180 days in seconds
              };
            };
          };
          Documents = mkIf (builtins.hasAttr "Documents" cfg.folders) {
            id = "Documents";
            path = cfg.folders.Documents.path;
            devices = [
              "JASPER-PC"
              "jasper-void"
              "ptolemy"
              "zenfone-9"
              "xperia-1-vii"
            ];
            versioning = {
              type = "staggered";
              params = {
                cleanInterval = "3600"; # 1 hour in seconds
                maxAge = "15552000"; # 180 days in seconds
              };
            };
          };
          Homework = mkIf (builtins.hasAttr "Homework" cfg.folders) {
            id = "Homework";
            path = cfg.folders.Homework.path;
            devices = [
              "JASPER-PC"
              "jasper-void"
              "ptolemy"
            ];
            versioning = {
              type = "staggered";
              params = {
                cleanInterval = "3600"; # 1 hour in seconds
                maxAge = "15552000"; # 180 days in seconds
              };
            };
          };
          remarkable_sync = mkIf (builtins.hasAttr "remarkable_sync" cfg.folders) {
            type = "receiveonly";
            id = "remarkable_sync";
            path = cfg.folders.remarkable_sync.path;
            devices = [
              "JASPER-PC"
              "jasper-void"
              "ptolemy"
              "remarkable"
              "zenfone-9"
              "xperia-1-vii"
            ];
            versioning = {
              type = "staggered";
              params = {
                cleanInterval = "3600"; # 1 hour in seconds
                maxAge = "15552000"; # 180 days in seconds
              };
            };
          };
          pdf2remarkable = mkIf (builtins.hasAttr "pdf2remarkable" cfg.folders) {
            id = "pdf2remarkable";
            path = cfg.folders.pdf2remarkable.path;
            devices = [
              "JASPER-PC"
              "jasper-void"
              "ptolemy"
              "remarkable"
              "zenfone-9"
              "xperia-1-vii"
            ];
          };
        };
        options = {
          urAccepted = 3; # Allow usage reporting
        };
        gui = {
          user = "jasper";
          password = cfg.guiPassword;
        };
      };
    };
  };
}
