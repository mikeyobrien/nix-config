{ config, pkgs, lib, home-manager, ... }:

{
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
      shell = pkgs.fish;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.mikeyobrien = import ./home.nix;
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
  ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/.config/nix-darwin/mobrien-mbp19/configuration.nix";

  # auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
