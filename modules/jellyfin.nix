{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  users.groups.render.members = [ "jellyfin" ];
  users.groups.video.members = [ "jellyfin" ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}


