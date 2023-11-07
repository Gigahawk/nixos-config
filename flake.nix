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
      #url = "github:hercules-ci/arion";
      url = "github:Gigahawk/arion/stop_grace_period";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = inputs @ { nixpkgs, home-manager, agenix, arion, flake-utils, ... }:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    overlays = { pkgs, config, ... }: {
      config.nixpkgs.overlays = [
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
  } // (
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShell = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.vim
            agenix.packages.${system}.agenix
          ];
          shellHook = ''
            export EDITOR=vim
            '';
        };
      }
    )
  );
}

