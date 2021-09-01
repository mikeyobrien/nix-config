{
  description = "Mac Systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { darwin, home-manager, nixpkgs, ... }: {
    darwinConfigurations."mobrien-mbp19" = darwin.lib.darwinSystem {
      modules = [ ./mobrien-mbp19/configuration.nix ];
      inputs = { inherit home-manager nixpkgs; };
    };
  };
}
