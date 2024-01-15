{ pkgs, ... }: {
  imports = [
    "${
      fetchTarball
      "https://github.com/NixOS/nixos-hardware/archive/32f61571b486efc987baca553fb35df22532ba63.tar.gz"
    }/raspberry-pi/4"
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };


}
