{ config, pkgs, lib, home-manager, ... }:

{
  environment.darwinConfig = "$HOME/.config/nix-macos/mobrien-mbp19/configuration.nix";

  nix.package = pkgs.nixFlakes;
  nix.extraOptions = lib.optionalString (config.nix.package == pkgs.nixFlakes)
    "experimental-features = nix-command flakes";

  nix.trustedUsers = [ "mikeyobrien" "@admin" ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  users = {
    users.mikeyobrien = {
      name = "mikeyobrien";
      home = "/Users/mikeyobrien";
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.mikeyobrien = import ./home.nix;
  };

  environment.systemPackages = with pkgs; [
    git
    curl
  ];

  programs.fish.enable = true;

  system.stateVersion = 4;
}
