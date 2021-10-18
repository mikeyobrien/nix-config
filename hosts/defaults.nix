{ pkgs, lib, config, ... }:

with builtins;
{
  fonts.fonts = with pkgs; [
    iosevka
    nerdfonts
  ];

  environment.systemPackages = with pkgs; [
    gnumake
    git
    vim
    wget
    jq
  ];
}
