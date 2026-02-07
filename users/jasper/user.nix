{
  config,
  pkgs,
  lib,
  inputs,
  desktop,
  ...
}:
{
  imports = [
    (import inputs.home-manager.nixosModules.home-manager)
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  users.users.jasper = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.jasper.path;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "docker"
      "input"
      "video" # Allow vcgencmd to work on rpi
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # JASPER-PC Ubuntu WSL
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIjA/h30yvAJQkkfMBncAKo2aY1dzb+2m/eWw3MLfV76 jasper"
      # veda
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFuW7/do+fI6PCEQdb+Ui0zBPlZvo/YKf5Nl6uujoPl2 jasper"
      # virtualbox
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBoOvyE+sGI2jS1owqCXlHpqZcVOSrJwe6QPH5pnTpq jasper"
      # arios
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSsOe84SBbBKRQwWuU1rl3SUeHArkWymY4PMqtaPPI3 jasper"
      # ptolemy
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJbLOr4BdW+2IilSgP3M8RVvZ3TErl0TmY42Bcffsb9 jasper"
    ];
  };

  fonts.packages = [
  ]
  ++ (
    if desktop then
      with pkgs;
      [
        roboto
        nerd-fonts.symbols-only
      ]
    else
      [ ]
  );

  nixpkgs.config.permittedInsecurePackages = [
  ]
  ++ (
    if desktop then
      [
        # KDE Itinerary uses this for matrix sync
        # or something
        "olm-3.2.16"
      ]
    else
      [ ]
  );

  environment.systemPackages = [
  ]
  ++ (
    if desktop then
      with pkgs;
      [
        brightnessctl
        freecad
        gparted
        wlogout
        kdePackages.itinerary
        kdePackages.okular
        libreoffice
        localsend
        piper
        prusa-slicer
        remmina
        mayo
        yt-dlp
        zathura
      ]
    else
      [ ]
  );

  services.ratbagd.enable = desktop;

  services.displayManager.ly = {
    enable = lib.mkDefault desktop;
    settings = {
      animation = "matrix";
      bigclock = "en";
      clock = "%c";
    };
  };

  # Fallback for when wayland breaks/virtualbox
  services.xserver.enable = lib.mkDefault desktop;
  services.xserver.windowManager.icewm.enable = lib.mkDefault desktop;

  programs.kdeconnect.enable = desktop;

  programs.hyprland = {
    enable = lib.mkDefault desktop;
    xwayland.enable = true;
  };

  home-manager.extraSpecialArgs = {
    inherit desktop;
    inherit inputs;
  };

  home-manager.users.jasper = ./home.nix;
}
