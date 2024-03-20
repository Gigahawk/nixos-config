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
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xmpp-bridge = {
      url = "github:Gigahawk/xmpp-bridge-py";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bcrypt-tool = {
      url = "github:Gigahawk/bcrypt-tool";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    smartp = {
      url = "github:Gigahawk/smartp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    inventree = {
      url = "github:Gigahawk/nixos-inventree";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-top = {
      url = "github:Gigahawk/nix-top";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
      # nixos-hardware doesn't rely on nixpkgs
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    agenix,
    arion,
    flake-utils,
    nixos-generators,
    xmpp-bridge,
    bcrypt-tool,
    inventree,
    nix-top,
    nixos-hardware,
    ... }:
  let
    lib = nixpkgs.lib;
    mkSdImage = host:
      (self.nixosConfigurations.${host}.extendModules {
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        ];
      }).config.system.build.sdImage;
    overlays = { pkgs, config, ... }: {
      config.nixpkgs.overlays = [
        # TODO: does this cause problems for other systems?
        # The following is requried for building RPi images {
        # https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
        (final: super: {
          makeModulesClosure = x:
            super.makeModulesClosure (x // { allowMissing = true; });
        })
      ];
    };
  in {
    images = {
      haro = mkSdImage "haro";
    };
    nixosConfigurations = {
      # Main server
      ptolemy = let
        system = "x86_64-linux";
      in
        lib.nixosSystem {
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
            ./modules/snapraid/module.nix
            ./modules/xmpp-bridge/module.nix
            ./modules/smartp/module.nix
            ./modules/syncthing.nix
            ./modules/jellyfin.nix
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
      # Main server Pi KVM
      haro = let
        system = "aarch64-linux";
      in
        lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit system;
          };
          modules = [
            overlays
            ./configuration.nix
            agenix.nixosModules.default
            ./modules/agenix-cli.nix
            #./modules/xmpp-bridge/module.nix
            ./modules/raspi4
            ./hosts/haro/configuration.nix
            ./hosts/haro/hw-config.nix
            ./users/jasper/user.nix
          ];

        };
      # Test server
      virtualbox = let
        system = "x86_64-linux";
      in
        lib.nixosSystem {
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
            ./modules/snapraid/module.nix
            ./modules/xmpp-bridge/module.nix
            inventree.nixosModule
            ./modules/inventree-backup/module.nix
            ./modules/immich/immich.nix
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
            pkgs.nix-output-monitor # Better nix build output
            pkgs.vim
            pkgs.openssh
            pkgs.rsync
            pkgs.jq
            pkgs.systemd  # Read journalctl logs locally
            pkgs.mkpasswd  # Generate password hashes
            pkgs.syncthing  # Generate syncthing keys
            agenix.packages.${system}.agenix
            bcrypt-tool.packages.${system}.default
            pkgs.nixos-rebuild  # Build test systems locally
            inventree.packages.${system}.inventree-gen-secret  # Generate secret_key.txt
            pkgs.zstd  # Compress/decompress Pi images
            pkgs.unixtools.fdisk
          ];
          shellHook = ''
            export EDITOR=vim
            '';
        };
      }
    )
  );
}

