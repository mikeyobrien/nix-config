{
  description = "NixOS and nix-darwin configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";

    # overlays
    emacs.url = "github:nix-community/emacs-overlay";
  };


  outputs = inputs@{ self, darwin, home-manager, emacs, nixpkgs, ... }:
  let
    inherit (nixpkgs) lib;
    homeManagerCommonConfig = with self.homeManagerModules; {
      imports = [ ./home ];
    };

    platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllPlatforms = f: lib.genAttrs platforms (platform: f platform);
    nixpkgsFor = forAllPlatforms (platform: import nixpkgs {
      system = platform;
      overlays = builtins.concatLists [
        (lib.optional (platform == "aarch64-darwin")
        # Apple Silicon backport overlay:
        # In other words, x86 packages to install instead of
        # arm packages which don't build yet for any reason
        (self: super: {
          # This is bad for libraries but okay for programs.
          # See: https://github.com/LnL7/nix-darwin/issues/334#issuecomment-850857148
          # For libs, I will use pkgsX86 defined below.
          inherit (nixpkgsX86darwin) yabai kitty nixfmt clojure-lsp pandoc black mosh;
        }))
      ];
      config.allowUnfree = true;
    });

    nixpkgsX86darwin = import nixpkgs {
      localSystem = "x86_64-darwin";
    };

    mkDarwinSystem = { locals, specialArgs, modules, system }:
      darwin.lib.darwinSystem {
        inherit specialArgs system;
        inputs = {
          inherit darwin nixpkgs emacs home-manager locals;
        };
        modules = modules ++ [
          home-manager.darwinModules.home-manager
          ./modules/brew.nix
          ./modules/k8s.nix
          {
            home-manager.users.${locals.username} = with self.homeManagerModules; {
              _module.args.locals = locals;
              imports = [ ./home ];
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
       ];
    };
  in {
    nixosConfigurations = {
      sculpin = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./hosts/sculpin/configuration.nix
          ./modules/options.nix
          ./modules/bspwm.nix
          ./modules/tmux.nix
          ./home/modules/neovim.nix
          ./home/modules/alacritty.nix
       ];
     };
     squid = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./hosts/squid/configuration.nix
          ./modules/options.nix
          ./modules/bspwm.nix
          ./modules/tmux.nix
          ./home/modules/neovim.nix
          ./home/modules/alacritty.nix
        ];
      };
    };
    darwinConfigurations = {
      "mobrien-mbp19" = mkDarwinSystem {
        system = "x86_64-darwin";
        specialArgs = {};
        modules = [
          ./hosts/mobrien-mbp19/configuration.nix
          ./hosts/squid/configuration.nix
          ./modules/options.nix
          ./modules/bspwm.nix
          ./modules/tmux.nix
          ./home/modules/neovim.nix
          ./home/modules/alacritty.nix
        ];
      };
      "m1macbook" = mkDarwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          pkgs = nixpkgsFor.aarch64-darwin;
          pkgsX86 = nixpkgsX86darwin;
        };
      };
    };
  };
}
