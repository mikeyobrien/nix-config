{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    ../macos-defaults.nix
  ];


  environment.darwinConfig = "$HOME/.config/nix-macos/hosts/mobrien-mbp19/configuration.nix";
  environment.systemPackages = with pkgs; [
    cachix
    fish
    zsh
    bashInteractive
    apacheKafka

    jdk11
    go
    gopls
    ffmpeg
    gifsicle
  ];

  modules.brew = {
    enable = true;
    casks = [
      "iterm2"
      "docker"
    ];
    brews = [
      "pulumi"
      "tfenv"
    ];
    extraConfig = ''
      brew "emacs-plus@28", args: ["with-native-comp", "with-no-titlebar"]
    '';
  };


  home.homeDirectory = "/Users/mikeyobrien";

  services.kubernetes.enable = true;

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
