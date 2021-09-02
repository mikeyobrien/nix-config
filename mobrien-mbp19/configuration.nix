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

  environment.systemPackages = with pkgs; [
    fish
    zsh
    bashInteractive
  ];

  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.fish.useBabelfish = true;
  programs.fish.babelfishPackage = pkgs.babelfish;

  programs.fish.shellInit = ''
    for p in (string split : ${config.environment.systemPath})
      if not contains $p $fish_user_paths
        set -g fish_user_paths $fish_user_paths $p
      end
    end
  '';
  environment.variables.SHELL = "${pkgs.fish}/bin/fish";

  system.stateVersion = 4;
}
