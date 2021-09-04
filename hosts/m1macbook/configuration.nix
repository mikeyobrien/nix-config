{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    ../macos-defaults.nix
  ];

  environment.darwinConfig = "$HOME/.config/nix-macos/m1macbook/configuration.nix";
  environment.systemPackages = with pkgs; [
    vim
  ];

  programs.fish.enable = true;
  modules.brew.enable = true;

  services.nix-daemon.enable = false;
  system.stateVersion = 4;
}
