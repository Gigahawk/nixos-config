{
  config,
  pkgs,
  ...
}: {
  home.username = "jasper";
  home.homeDirectory = "/home/jasper";

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;
}
