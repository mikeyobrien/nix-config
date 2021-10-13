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
  in {
    nixosConfigurations = {
      squid =  nixpkgs.lib.nixosSystem {
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
  };
}
