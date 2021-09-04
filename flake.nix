{
  description = "Mac Systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";

    # overlays
    emacs-overlay.url = "github:nix-community/emacs-overlay";

    # doom
    doom-emacs = {
      url = "github:hlissner/doom-emacs/develop";
      flake = false;
    };
  };


  outputs = inputs@{ self, darwin, home-manager, doom-emacs, nixpkgs, ... }:
  let
    homeManagerCommonConfig = with self.homeManagerModules; {
      imports = [ ./home ];
    };
  in {
    nixosConfigurations.nixos =  nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nix-wsl/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.users.mikeyobrien = homeManagerCommonConfig;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
    };

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
        inputs = { inherit doom-emacs; };
      };
      "m1macbook" = darwin.lib.darwinSystem {
        modules = [
          ./hosts/m1macbook/configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.users.mikeyobrien = homeManagerCommonConfig;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
  };
};
}
