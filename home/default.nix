{ pkgs, lib, config, ... }:

with builtins;
{
  inherit lib;
  imports = [
    ./fish.nix
  ];

  home.file.".doom.d".source = config.lib.file.mkOutOfStoreSymlink /etc/nixos/home/doom.d;

  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    babashka
    fish
    awscli
    starship
    htop
    jetbrains-mono
    ripgrep
    fzf
    fd
    bat
    diff-so-fancy
    thefuck
    delta
    jq
    git-lfs
    ranger
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
    nix-direnv.enableFlakes = true;
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
    settings = {
      git_status = {
        disabled = true;
      };
    };
  };
  programs.git = {
    enable  = true;
    userName = "Mikey O'Brien";
    userEmail = "mobrien@vectra.ai";
    lfs.enable = true;
    aliases = {
      ca         = "commit --amend";
      changes    = "diff --name-status -r --color | diff-so-fancy";
      spull      = "!${pkgs.git}/bin/git stash"
                    + " && ${pkgs.git}/bin/git pull"
                    + " && ${pkgs.git}/bin/git stash pop";
    };
    extraConfig = {
      http = { postBuffer = 524288000; };
      core = { compression = 0; };
      "includeIf \"vectra/\"" = { path = ".gitconfig-vectra"; };
      "includeIf \"code/\"" = { path = ".gitconfig-code"; };
    };
  };
}
