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
      url = "github:Gigahawk/nixos-inventree/uv";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    kvmd = {
      url = "github:Gigahawk/nixos-kvmd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cypress-ticket-scraper = {
      url = "github:Gigahawk/cypress-ticket-scraper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-top = {
      url = "github:Gigahawk/nix-top";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      # HACK: prevent skipped overlays https://github.com/NixOS/nixos-hardware/issues/1529
      # HACK: support 4 lane CSI https://github.com/NixOS/nixos-hardware/pull/1530
      url = "github:Gigahawk/nixos-hardware/personal";
      #url = "github:nixos/nixos-hardware";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-remote-workaround = {
      url = "github:Gigahawk/vscode-remote-workaround/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    agenix,
    flake-utils,
    nixos-generators,
    xmpp-bridge,
    bcrypt-tool,
    inventree,
    kvmd,
    cypress-ticket-scraper,
    nix-top,
    nixos-hardware,
    nixos-wsl,
    vscode-remote-workaround,
    ... }:
  let
    lib = nixpkgs.lib;
    mkSdImage = host:
      self.nixosConfigurations.${host}.config.system.build.sdImage;
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
            ./configuration.nix
            ./modules/neovim/module.nix
            agenix.nixosModules.default
            ./modules/tailscale-autoconnect/module.nix
            ./modules/agenix-cli.nix
            ./modules/snapraid/module.nix
            ./modules/xmpp-bridge/module.nix
            ./modules/smartp/module.nix
            ./modules/smartd.nix
            ./modules/syncthing.nix
            ./modules/jellyfin.nix
            ./modules/immich/immich.nix
            inventree.nixosModule
            cypress-ticket-scraper.nixosModule
            ./modules/inventree-backup/module.nix
            ./modules/restic/module.nix
            ./modules/notify-startup-shutdown/module.nix
            ./modules/ghidra-server/module.nix
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
      # WSL on JASPER-PC
      veda = let
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
            nixos-wsl.nixosModules.default
            ./configuration.nix
            agenix.nixosModules.default
            vscode-remote-workaround.nixosModules.default
            ./modules/agenix-cli.nix
            ./hosts/veda/configuration.nix
            #./hosts/veda/hw-config.nix
            ./modules/neovim/module.nix
            ./users/jasper/user.nix
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
            kvmd.nixosModule
            ./modules/tailscale-autoconnect/module.nix
            ./modules/agenix-cli.nix
            #./modules/xmpp-bridge/module.nix
            ./modules/raspi4/module.nix
            nixos-hardware.nixosModules.raspberry-pi-4
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
            ./configuration.nix
            ./modules/neovim/module.nix
            agenix.nixosModules.default
            ./modules/tailscale-autoconnect/module.nix
            ./modules/agenix-cli.nix
            ./modules/snapraid/module.nix
            ./modules/xmpp-bridge/module.nix
            inventree.nixosModule
            ./modules/inventree-backup/module.nix
            ./modules/ghidra-server/module.nix
            #./modules/restic/module.nix
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
      installer = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        specialArgs = {
          system = "x86_64-linux";
          inherit inputs;
        };
        modules = [
          ./configuration.nix
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
            pkgs.apacheHttpd  # Generate htpasswd files for kvmd
            pkgs.nix-output-monitor # Better nix build output
            pkgs.openssh
            pkgs.rsync
            pkgs.jq
            pkgs.systemd  # Read journalctl logs locally
            pkgs.mkpasswd  # Generate password hashes
            pkgs.syncthing  # Generate syncthing keys
            agenix.packages.${system}.agenix
            bcrypt-tool.packages.${system}.default
            pkgs.nixos-rebuild  # Build test systems locally
            inventree.packages.${system}.gen-secret  # Generate secret_key.txt
            pkgs.zstd  # Compress/decompress Pi images
            pkgs.unixtools.fdisk
          ];
        };
      }
    )
  );
}

