{
  description = "NixOS and nix-darwin configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    flake-utils.url = "github:numtide/flake-utils";

    # overlays
    emacs.url = "github:nix-community/emacs-overlay";
  };


  outputs = inputs@{ self, darwin, home-manager, emacs, nixpkgs, flake-utils, ... }:
  let
    inherit (nixpkgs) lib;
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
          ./home/modules/emacs.nix
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
        ./home/modules/emacs.nix
      ];
    };
  };

    homeConfigurations = {
      mobrien-mbp19 = inputs.home-manager.lib.homeManagerConfiguration {
      configuration = ./hosts/mobrien-mbp19;
      extraModules = [
        ./home
        ./home/modules/options.nix
        ./home/modules/neovim.nix
        ./modules/tmux.nix
      ];
      system = "x86_64-darwin";
      homeDirectory = "/Users/mikeyobrien";
      username = "mikeyobrien";
    };
   };
  };
}
