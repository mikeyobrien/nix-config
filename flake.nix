{
  description = "Mac Systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
  };


  outputs = inputs@{ self, darwin, home-manager, nixpkgs, ... }:
  let
    homeManagerCommonConfig = with self.homeManagerModules; {
      imports = [ ./home ];
    };
  in {
    darwinConfigurations = {
      "mobrien-mbp19" = darwin.lib.darwinSystem {
        modules = [
          ./mobrien-mbp19/configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.users.mikeyobrien = homeManagerCommonConfig;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
      "m1macbook" = darwin.lib.darwinSystem {
        modules = [
          ./m1macbook/configuration.nix
          home-manager.darwinModules.home-manager
        ];
      };
    };
  };
}
