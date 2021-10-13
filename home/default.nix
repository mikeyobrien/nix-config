{ pkgs, lib, config, ... }:

with builtins;
{
  inherit lib;
  imports = [
    ./fish.nix
  ];

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    starship
    htop
    jetbrains-mono
    ripgrep
    fzf
    fd
    bat
    diff-so-fancy
    thefuck
    direnv
    delta
    jq
    git-lfs
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.bat.enable = true;
  programs.direnv.enable = true;
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
    userName = "Mikey O'Brien";
    userEmail = "mobrien@vectra.ai";
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
