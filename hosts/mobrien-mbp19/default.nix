{ pkgs, ... }:

{
  home.packages = [
    pkgs.htop
    pkgs.fortune
  ];

  modules.neovim.enable = true;
  modules.tmux.enable = true;

  programs.home-manager = {
    enable = true;
  };
}


