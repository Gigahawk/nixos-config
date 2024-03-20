# Based on https://kressle.in/articles/2023/immich-on-docker-with-nixos.php
{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.services.immich;
  version = "1.99.0";
in {

  options.services.immich = {
    enable = mkEnableOption
      (lib.mdDoc "High performance self-hosted photo and video management solution.");

    port = mkOption {
      type = types.int;
      default = 2283;
      description = mdDoc ''
        Port to run the server on
      '';
    };

    dataPath = mkOption {
      type = types.str;
      default = "immich-data";
      description = mdDoc ''
        Path or docker volume name to store Immich data in
      '';
    };

    # TODO: is there a way to configure this automatically?
    timezone = mkOption {
      type = types.str;
      default = "Canada/Pacific";
      description = mdDoc ''
        Timezone of the server
      '';
    };

    dbPath = mkOption {
      type = types.str;
      default = "immich-db";
      description = mdDoc ''
        Path or docker volume name to store Immich database in
      '';
    };

    dbCredentialsFile = mkOption {
      type = types.path;
      description = lib.mdDoc ''
        Docker environment file containing the following keys:
        ```
        DB_USERNAME=postgres
        DB_PASSWORD=<DB_PASSWORD>
        POSTGRES_USER=postgres
        POSTGRES_PASSWORD=<DB_PASSWORD>
        ```
      '';
    };
  };

  config = mkIf cfg.enable ({

    systemd.services.init-filerun-network-and-files = {
      description = "Create the network bridge for Immich.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";
      script = let dockercli = "${config.virtualisation.docker.package}/bin/docker";
              in ''
                # immich-net network
                check=$(${dockercli} network ls | grep "immich-net" || true)
                if [ -z "$check" ]; then
                  ${dockercli} network create immich-net
                else
                  echo "immich-net already exists in docker"
                fi
              '';
    };

    virtualisation.oci-containers.containers = {
      immich-server = {
        autoStart = true;
        image = "ghcr.io/imagegenius/immich:${version}";
        volumes = [
          "${cfg.dataPath}/config:/config"
          "${cfg.dataPath}/photos:/photos"
          "${cfg.dataPath}/config/machine-learning:/config/machine-learning"
        ];
        ports = [ "${toString cfg.port}:8080" ];
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = cfg.timezone;
          DB_HOSTNAME = "immich-db";
          DB_DATABASE_NAME = "immich";
          REDIS_HOSTNAME = "immich-cache";
        };
        environmentFiles = [ cfg.dbCredentialsFile ];
        #extraOptions = [ "--network=immich-net" "--gpus=all" ];
        extraOptions = [ "--network=immich-net" "--pull=always" ];
      };

      immich-cache = {
        autoStart = true;
        image = "redis";
        ports = [ "6379:6379" ];
        extraOptions = [ "--network=immich-net" "--pull=always" ];
      };

      immich-db = {
        autoStart = true;
        image = "tensorchord/pgvecto-rs:pg14-v0.2.0";
        ports = [ "5432:5432" ];
        volumes = [
          "${cfg.dbPath}:/var/lib/postgresql/data"
        ];
        environment = {
          POSTGRES_DB = "immich";
        };
        environmentFiles = [ cfg.dbCredentialsFile ];
        extraOptions = [ "--network=immich-net" "--pull=always" ];
      };
  };
  });
}