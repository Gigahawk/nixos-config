{
  config,
  pkgs,
  ...
}:
let
  ports = import ../../ports.nix;
in

{
  services.nix-serve = {
    enable = true;
    port = ports.nix-serve-internal;
    secretKeyFile = config.age.secrets.nix-serve-private-key.path;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "${config.networking.hostName}.neon-chameleon.ts.net" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = ports.nix-serve-external;
          }
        ];
        locations."/".proxyPass =
          "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    ports.nix-serve-external
  ];
}
