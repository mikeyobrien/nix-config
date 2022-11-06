{
  description = "NixOS and nix-darwin configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";

      # We want home-manager to use the same set of nixpkgs as our system.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };


  outputs = inputs@{ self, home-manager, nixpkgs, ... }:
  let
    mkConfig = import ./lib/mkConfig.nix;
    overlays = [
      inputs.neovim-nightly-overlay.overlay
    ];
  in {
    nixosConfigurations = {
      vm-aarch64 = mkConfig "vm-aarch64" rec {
        inherit nixpkgs home-manager overlays;
        system = "aarch64-linux";
        name = "vm-aarch64";
        user = "mobrienv";
     };
    };
  };
}
