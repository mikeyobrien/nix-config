{
  description = "Mac Systems";

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
          inherit (nixpkgsX86darwin) yabai kitty nixfmt clojure-lsp;
        }))
      ];
      config.allowUnfree = true;
    });

    nixpkgsX86darwin = import nixpkgs {
      localSystem = "x86_64-darwin";
    };

    mkDarwinSystem = { localConfig, modules }:
      darwin.lib.darwinSystem {
        inputs = {
          inherit darwin nixpkgs emacs home-manager;
        };
        specialArgs = {
          pkgs = nixpkgsFor.aarch64-darwin;
          pkgsX86 = nixpkgsX86darwin;
        };
        modules = modules ++ [
          home-manager.darwinModules.home-manager
          {
            home-manager.users.${localConfig.username} = homeManagerCommonConfig;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
       ];
    };
  in {
    nixosConfigurations.nixos =  nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nix-wsl/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
    };

    darwinConfigurations = {
      "mobrien-mbp19" = darwin.lib.darwinSystem {
        inputs = {
          inherit emacs;
          isDarwin  = true;
        };
        modules = [
          ./mobrien-mbp19/configuration.nix
          ./modules/brew.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
      "m1macbook" = mkDarwinSystem {
        localConfig = {
          username = "mikeyobrien";
          git.name = "Mikey O'Brien";
          git.email  = "hmobrienv@gmail.com";
        };
        modules = [
          ./hosts/m1macbook/configuration.nix
          ./modules/brew.nix
        ];
      };
  };
};
}
