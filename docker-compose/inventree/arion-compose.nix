{ pkgs, ... }:
{
  # arion generates a network named "inventree" which can't have the same
  # name as the project name
  project.name = "inventree-project";
  services =
  let
    nginx_config = pkgs.writeText "nginx.prod.conf" (builtins.readFile ./nginx.prod.conf);
    backup_script = pkgs.writeScript "backup.sh" (builtins.readFile ./backup.sh);
    backup_script_container_path = "/home/inventree/backup.sh";
    inventree_version = "0.13.0";
    inventree_web_port = "1337";
    inventree_db_name = "inventree";
    inventree_db_port = "5432";
    inventree_db_user = "pguser";
    inventree_db_password = "pgpassword";
    inventree_cache_port = "6379";
    inventree_data_path = /mnt/pool/inventree-data;
    inventree_backup_path = /mnt/pool/inventree-backup;
    inventree_data_volumes = [
      "${toString inventree_data_path}:/home/inventree/data"
    ];
    inventree_environment = {
      INVENTREE_EXT_VOLUME = "${toString inventree_data_path}";

      INVENTREE_WEB_PORT = inventree_web_port;

      INVENTREE_DEBUG = "False";
      INVENTREE_LOG_LEVEL = "WARNING";

      INVENTREE_DB_ENGINE = "postgresql";
      INVENTREE_DB_NAME = inventree_db_name;
      INVENTREE_DB_HOST = "inventree-db";
      INVENTREE_DB_PORT = inventree_db_port;

      INVENTREE_DB_USER = inventree_db_user;
      INVENTREE_DB_PASSWORD = inventree_db_password;

      #INVENTREE_CACHE_HOST = "inventree-cache";
      #INVENTREE_CACHE_PORT = inventree_cache_port;

      INVENTREE_GUNICORN_TIMEOUT = 90;

      INVENTREE_PLUGINS_ENABLED = "True";

      INVENTREE_TAG = inventree_version;

      COMPOSE_PROJECT_NAME = "inventree-production";
    };
  in
  {
    inventree-db.service = {
      image = "postgres:13";
      expose = ["${inventree_db_port}/tcp"];
      environment = {
        PGDATA = "/var/lib/postgresql/data/pgdb";
        POSTGRES_USER = inventree_db_user;
        POSTGRES_PASSWORD= inventree_db_password;
        POSTGRES_DB= inventree_db_name;
      };
      volumes = [
        "${toString inventree_data_path}:/var/lib/postgresql/data"
      ];
      restart = "unless-stopped";
    };
    #inventree-cache.service = {
    #  image = "redis:7.0";
    #  depends_on = ["inventree-db"];
    #  environment = inventree_environment;
    #  expose = [inventree_cache_port];
    #  restart = "always";
    #};
    inventree-server.service = {
      image = "inventree/inventree:${inventree_version}";
      expose = ["8000"];
      depends_on = ["inventree-db"];
      environment = inventree_environment;
      restart = "unless-stopped";
      volumes = inventree_data_volumes;
    };
    inventree-worker.service = {
      image = "inventree/inventree:${inventree_version}";
      command = "invoke worker";
      depends_on = ["inventree-server"];
      environment = inventree_environment;
      volumes = inventree_data_volumes;
    };
    inventree-proxy.service = {
      image = "nginx:stable";
      depends_on = ["inventree-server"];
      environment = inventree_environment;
      ports = ["${inventree_web_port}:80"];
      volumes = [
        "${toString nginx_config}:/etc/nginx/conf.d/default.conf:ro"
        "${toString inventree_data_path}:/var/www"
      ];
      restart = "unless-stopped";
    };
    inventree-backup.service = {
      image = "inventree/inventree:${inventree_version}";
      stop_grace_period = "5s";
      command = backup_script_container_path;
      depends_on = [ "inventree-db" "inventree-server" ];
      environment = inventree_environment;
      volumes = [
        "${toString backup_script}:${backup_script_container_path}"
        "${toString inventree_data_path}:/home/inventree/data"
        "${toString inventree_backup_path}:/home/inventree/backup"
      ];
      restart = "unless-stopped";
    };
  };
}