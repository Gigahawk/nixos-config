{
  description = "System Config";

  inputs = {
    # Waiting for mayo to be merged https://github.com/NixOS/nixpkgs/pull/442185
    # Waiting for this ceph build fix to be merged https://github.com/NixOS/nixpkgs/pull/462435
    #nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs.url = "github:Gigahawk/nixpkgs/personal";
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
      url = "github:Gigahawk/nixos-inventree";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    kvmd = {
      url = "github:Gigahawk/nixos-kvmd";
      # building off personal nixpkgs means we have to rebuild proxy-py
      # which fails when building on qemu-user
      #inputs.nixpkgs.follows = "nixpkgs";
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
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    declarative-jellyfin = {
      url = "github:Sveske-Juice/declarative-jellyfin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nnn-plugins = {
      url = "github:jarun/nnn";
      flake = false;
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
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
      nvf,
      declarative-jellyfin,
      treefmt-nix,
      ...
    }:
    let
      lib = nixpkgs.lib;
      mkSdImage = host: self.nixosConfigurations.${host}.config.system.build.sdImage;
      overlays =
        {
          pkgs,
          config,
          ...
        }:
        {
          config.nixpkgs.overlays = [
            # TODO: does this cause problems for other systems?
            # The following is requried for building RPi images {
            # https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
            (final: super: {
              makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
            })
            (import ./overlays/python.nix)
          ];
        };
    in
    {
      images = {
        haro = mkSdImage "haro";
      };
      nixosConfigurations = {
        # Main server
        ptolemy =
          let
          in
          lib.nixosSystem {
            specialArgs = {
              inherit inputs;
              # ptolemy runs a basic desktop env for easy pikvm
              # access but we don't really want anything too fancy
              # or shortcut heavy like the standard hyprland setup
              desktop = false;
            };
            modules = [
              overlays
              ./configuration.nix
              ./modules/neovim/module.nix
              agenix.nixosModules.default
              ./modules/agenix-cli.nix
              ./modules/snapraid/module.nix
              ./modules/xmpp-bridge/module.nix
              ./modules/samba-users/module.nix
              ./modules/smartp/module.nix
              ./modules/smartd.nix
              ./modules/syncthing.nix
              ./modules/jellyfin.nix
              inventree.nixosModule
              cypress-ticket-scraper.nixosModule
              ./modules/inventree-backup/module.nix
              ./modules/restic/module.nix
              ./modules/notify-startup-shutdown/module.nix
              ./modules/ghidra-server/module.nix
              ./hosts/ptolemy/configuration.nix
              ./hosts/ptolemy/hw-config.nix
              ./users/jasper/user.nix
            ];
          };
        # WSL on JASPER-PC
        veda =
          let
          in
          lib.nixosSystem {
            specialArgs = {
              inherit inputs;
              desktop = false;
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
        haro =
          let
          in
          lib.nixosSystem {
            specialArgs = {
              inherit inputs;
              desktop = false;
            };
            modules = [
              overlays
              ./configuration.nix
              agenix.nixosModules.default
              kvmd.nixosModule
              ./modules/agenix-cli.nix
              #./modules/xmpp-bridge/module.nix
              ./modules/raspi4/module.nix
              ./modules/managed-wifi/module.nix
              nixos-hardware.nixosModules.raspberry-pi-4
              ./hosts/haro/configuration.nix
              ./hosts/haro/hw-config.nix
              ./users/jasper/user.nix
            ];
          };
        # Test server
        virtualbox =
          let
          in
          lib.nixosSystem {
            specialArgs = {
              inherit inputs;
              desktop = true;
            };
            modules = [
              overlays
              ./configuration.nix
              ./modules/neovim/module.nix
              agenix.nixosModules.default
              ./modules/agenix-cli.nix
              ./modules/snapraid/module.nix
              ./modules/xmpp-bridge/module.nix
              inventree.nixosModule
              #./modules/inventree-backup/module.nix
              #./modules/ghidra-server/module.nix
              #./modules/restic/module.nix
              ./hosts/virtualbox/configuration.nix
              ./hosts/virtualbox/hw-config.nix
              ./users/jasper/user.nix
            ];
          };
        # Thinkpad x250
        arios =
          let
          in
          lib.nixosSystem {
            specialArgs = {
              inherit inputs;
              desktop = true;
            };
            modules = [
              overlays
              ./configuration.nix
              ./modules/neovim/module.nix
              agenix.nixosModules.default
              ./modules/agenix-cli.nix
              ./hosts/arios/configuration.nix
              ./hosts/arios/hw-config.nix
              ./users/jasper/user.nix
            ];
          };
      };
      #packages.x86_64-linux = {
      #  installer = nixos-generators.nixosGenerate {
      #    specialArgs = {
      #      inherit inputs;
      #    };
      #    modules = [
      #      ./configuration.nix
      #      ./hosts/installer/configuration.nix
      #    ];
      #    format = "install-iso";
      #  };
      #};
    }
    // (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        formatter = treefmtEval.config.build.wrapper;
        checks = {
          formatting = treefmtEval.config.build.check self;
        };
        packages = {
          nvim =
            (nvf.lib.neovimConfiguration {
              inherit pkgs;
              modules = [
                ./modules/neovim/nvim-config.nix
              ];
            }).neovim;
        };
        devShell = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.apacheHttpd # Generate htpasswd files for kvmd
            pkgs.nix-output-monitor # Better nix build output
            pkgs.openssh
            pkgs.rsync
            pkgs.jq
            pkgs.systemd # Read journalctl logs locally
            pkgs.mkpasswd # Generate password hashes
            pkgs.syncthing # Generate syncthing keys
            agenix.packages.${system}.agenix
            bcrypt-tool.packages.${system}.default
            pkgs.nixos-rebuild # Build test systems locally
            inventree.packages.${system}.gen-secret # Generate secret_key.txt
            pkgs.zstd # Compress/decompress Pi images
            pkgs.unixtools.fdisk
          ];
        };
      }
    ));
}
