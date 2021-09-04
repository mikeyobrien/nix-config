{ config, pkgs, lib, system, doom-emacs, ... }:

with builtins;
let
  homesRoot = "/Users/mikeyobrien";
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);
in
{
  imports = [
    ./neovim.nix
    ./fish.nix
  ];

  programs.home-manager.enable = true;

  home.username = "mikeyobrien";
  home.homeDirectory = "${homesRoot}";
  home.sessionPath = [ "${homesRoot}/.emacs.d/bin" ];
  home.sessionVariables = {
    EDITOR = "nvim";
    DOOMDIR = "${config.xdg.configHome}/doom-config";
  };

  # create the backup directory
  home.file.".config/nvim/backup/.keep".text = "";

  home.packages = with pkgs; [
    fish
    starship
    htop
    jetbrains-mono
    ripgrep
    fzf
    fd
    bat
    diff-so-fancy
    clojure-lsp
    thefuck
    gopls
    direnv
    delta
  ];

  xdg = {
    enable = true;
    configFile = {
      "doom-config/config.el".text = builtins.readFile ./doom.d/config.el;
      "doom-config/init.el".text = builtins.readFile ./doom.d/init.el;
      "doom-config/packages.el".text = builtins.readFile ./doom.d/packages.el;
    };
  };

  programs.bat.enable = true;
  programs.direnv.enable = true;


  programs.emacs = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.ssh = {
    enable = true;
    forwardAgent = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.git = {
    enable  = true;
    aliases = {
      ca         = "commit --amend";
      changes    = "diff --name-status -r --color | diff-so-fancy";
      spull      = "!${pkgs.git}/bin/git stash"
                    + " && ${pkgs.git}/bin/git pull"
                    + " && ${pkgs.git}/bin/git stash pop";
    };
    extraConfig = {
      "includeIf \"vectra/\"" = { path = ".gitconfig-vectra"; };
      "includeIf \"code/\"" = { path = ".gitconfig-code"; };
    };
  };

  home.stateVersion = "21.03";
}
