{ pkgs, lib, config, locals, ... }:

with builtins;
{
  inherit lib;
  imports = [
    ./neovim.nix
    ./fish.nix
  ];

  programs.home-manager.enable = true;

  # create the backup directory
  home.file.".config/nvim/backup/.keep".text = "";
  home.file.".doom.d".source = config.lib.file.mkOutOfStoreSymlink ./doom.d;
  home.file.".config/sxhkd/sxhkdrc".source = ./configs/sxhkdrc;

  home.packages = with pkgs; [
    # staging before
    black
    pandoc
    alacritty

    nodejs

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

    # language servers
    rnix-lsp
  ];

  home.username = "mikeyobrien";
  home.homeDirectory = locals.homeDirectory;
  home.sessionPath = [ "${locals.homeDirectory}/.emacs.d/bin" ];
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
