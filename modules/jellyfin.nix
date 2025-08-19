{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.declarative-jellyfin.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  users.groups.render.members = [ "jellyfin" ];
  users.groups.video.members = [ "jellyfin" ];

  services.declarative-jellyfin = {
    enable = true;
    openFirewall = true;

    system = {
      UICulture = "en-US";
    };

    users = {
      jasper = {
        mutable = false;
        permissions = {
          isAdministrator = true;
        };
        hashedPasswordFile = config.age.secrets.jellyfin-password.path;
      };
    };
  };
}


