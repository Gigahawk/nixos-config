{
  description = "System Config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, home-manager, agenix, arion, ... }:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    overlays = { pkgs, config, ... }: {
      config.nixpkgs.overlays = [
        (import overlays/inventree.nix)
      ];
    };
  in {
    nixosConfigurations = {
      virtualbox = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit system;
        };
        modules = [
          overlays
          arion.nixosModules.arion
          ./configuration.nix
          agenix.nixosModules.default
          ./modules/agenix-cli.nix
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

