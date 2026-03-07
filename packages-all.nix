{
  pkgs,
  inputs,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      alejandra
      bat
      bc
      binwalk
      btop
      bmon
      cabextract
      cifs-utils
      cryptsetup
      dig
      dua
      dmidecode
      dos2unix
      evtest
      expect
      fastfetch
      ffmpeg
      file
      gdu
      gettext
      git
      git-lfs
      gnupg
      gopass
      gosu
      hddtemp
      hwinfo
      i2c-tools
      imagemagick
      iputils
      jq
      lm_sensors
      lsb-release
      lshw
      mokutil
      nethogs
      nix-output-monitor
      nix-tree
      nixfmt
      openssh
      p7zip
      samba4Full
      smartmontools
      syncthing
      tailscale
      traceroute
      tree
      unzip
      usbutils
      vim
      virtualgl
      wget
      xplr

      # Custom packages
      inputs.advcpmv.packages.${stdenv.hostPlatform.system}.default
      inputs.nix-top.packages.${stdenv.hostPlatform.system}.default
      inputs.hydrasect.packages.${stdenv.hostPlatform.system}.default
      inputs.agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
      (callPackage ./packages/nixos-update.nix { })
      (callPackage ./packages/nixos-update-local.nix { })
      (callPackage ./packages/nix-flake-init.nix { })
    ]
    ++ (
      if
        builtins.elem stdenv.hostPlatform.system [
          "i686-linux"
          "x86_64-linux"
          "x86_64-darwin"
        ]
      then
        [ mprime ]
      else
        [ ]
    );
}
