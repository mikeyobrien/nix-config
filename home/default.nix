{ pkgs, lib, config, locals, ... }:

with builtins;
{
  inherit lib;
  imports = [
    ./neovim.nix
    ./fish.nix
    ./modules/emacs.nix
  ];

  programs.home-manager.enable = true;

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
    thefuck
    direnv
    delta
  ];

  home.username = "mikeyobrien";
  home.homeDirectory = locals.homeDirectory;
  home.sessionPath = [ "${locals.homeDirectory}/.emacs.d/bin" ];
  home.sessionVariables = {
    EDITOR = "nvim";
  };

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
    doomDir = "${config.xdg.configHome}/doom-config";
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
    userName = locals.git.name;
    userEmail = locals.git.email;
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
