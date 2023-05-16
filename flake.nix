{
  description = "System Config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      virtualbox = lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          ./hosts/virtualbox/configuration.nix
          ./hosts/virtualbox/hw-config.nix
          ./users/jasper/user.nix
          #home-manager.nixosModules.home-manager {
          #  home-manager.useGlobalPkgs = true;
          #  home-manager.useUserPackages = true;
          #  home-manager.users.jasper = import ./users/jasper.nix;
          #}
        ];
      };
    };
  };
}

