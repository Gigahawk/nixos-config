# Based on https://git.lain.faith/haskal/dragnpkgs/src/commit/dfcb303eef8a59f1e2f451fd15745a63acd89b02/modules/ghidra-server/default.nix
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.ghidra-server;
  adminCli = pkgs.callPackage ./cli.nix {
    inherit (cfg) package jdkPackage directory;
  };
in {
  options.services.ghidra-server = {
    enable = mkEnableOption "ghidra-server";
    enableAdminCli = mkEnableOption "ghidra-svrAdmin" // { default = true; };
    package = mkPackageOption pkgs "ghidra" {  };
    jdkPackage = mkPackageOption pkgs "openjdk21" {  };
    host = mkOption {
      default = null;
      defaultText = literalExpression "null";
      example = literalExpression "\"myserver.lol\"";
      description = "Ghidra server hostname or IP.";
      type = types.str;
    };
    basePort = mkOption {
      default = 13100;
      description = "Ghidra server base port - the server will use 3 consecutive TCP ports starting from the provided port number.";
      type = types.port;
    };
    directory = mkOption {
      default = "/var/lib/ghidra-server";
      description = ''
        Directory for Ghidra server data, under `/var/lib` (for systemd `StateDirectory`)
      '';
      type = types.str;
    };
    user = mkOption {
      type = types.str;
      default = "ghidra";
      description = "User account under which ghidra server runs.";
    };
    group = mkOption {
      type = types.str;
      default = "ghidra";
      description = "Group account under which ghidra server runs.";
    };
  };

  config = mkIf cfg.enable {
    users.users."${cfg.user}" = {
      isSystemUser = true;
      home = cfg.directory;
      inherit (cfg) group;
      packages = [ cfg.package cfg.jdkPackage ];
    };

    users.groups."${cfg.group}" = {};

    systemd.services."ghidra-server" =
      let
        ghidra_log4j_config = ./custom.log4j.xml;
        ghidra_java_opt = "-Dlog4j.configurationFile=${ghidra_log4j_config} -Djava.net.preferIPv4Stack=true -Djava.io.tmpdir=/tmp -Djna.tmpdir=/tmp -Dghidra.tls.server.protocols=TLSv1.2;TLSv1.3 -Ddb.buffers.DataBuffer.compressedOutput=true -Xms396m -Xmx768m";
        ghidra_home = "${cfg.package}/lib/ghidra";
        ghidra_classpath = with builtins; let
          input = lib.readFile "${ghidra_home}/Ghidra/Features/GhidraServer/data/classpath.frag";
          inputSplit = split "[^\n]*ghidra_home.([^\n]*)\n" input;
          paths = map head (filter isList inputSplit);
        in ghidra_home + (concatStringsSep (":" + ghidra_home) paths);
        ghidra_mainclass = "ghidra.server.remote.GhidraServer";
        ghidra_args = "-a0 -u -p${toString cfg.basePort} -ip ${cfg.host} ${cfg.directory}/repositories";
      in {
        description = "Ghidra server";
        after = ["network.target"];
        serviceConfig = {
          ExecStart = "${cfg.jdkPackage}/bin/java ${ghidra_java_opt} -classpath ${ghidra_classpath} ${ghidra_mainclass} ${ghidra_args}";
          WorkingDirectory = cfg.directory;
          Environment = "GHIDRA_HOME=${ghidra_home}";
          User = cfg.user;
          Group = cfg.group;
          SuccessExitStatus = 143;

          # use StateDirectory to create home dir and additional needed dirs with overridden
          # permissions when the unit starts
          # this is needed because we'd like the group (ghidra) to have write access to the
          # directories here, particularly ~admin
          StateDirectory = "${cfg.directory} ${cfg.directory}/repositories ${cfg.directory}/repositories/~admin";
          StateDirectoryMode = "0770";

          PrivateTmp = true;
          NoNewPrivileges = true;
        };
        wantedBy = ["multi-user.target"];
      };
      environment.systemPackages = optionals cfg.enableAdminCli [ adminCli ];
  };
}
