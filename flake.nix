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
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xmpp-bridge = {
      url = "github:Gigahawk/xmpp-bridge";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    agenix,
    arion,
    flake-utils,
    nixos-generators,
    xmpp-bridge,
    ... }:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    overlays = { pkgs, config, ... }: {
      config.nixpkgs.overlays = [
      ];
    };
  in {
    nixosConfigurations = {
      # Main server
      ptolemy = lib.nixosSystem {
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
          ./modules/xmpp-bridge.nix
          ./hosts/ptolemy/configuration.nix
          ./hosts/ptolemy/hw-config.nix
          ./users/jasper/user.nix
          #home-manager.nixosModules.home-manager {
          #  home-manager.useGlobalPkgs = true;
          #  home-manager.useUserPackages = true;
          #  home-manager.users.jasper = import ./users/jasper.nix;
          #}
        ];
      };
      # Test server
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
    packages.x86_64-linux = {
      ptolemy-installer = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        modules = [
          ./hosts/installer/configuration.nix
        ];
        format = "install-iso";
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
            pkgs.systemd  # Read journalctl logs locally
            pkgs.mkpasswd  # Generate password hashes
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

