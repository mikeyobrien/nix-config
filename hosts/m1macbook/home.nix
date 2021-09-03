{ config, pkgs, lib, ... }:

with builtins;

{
  programs.home-manager.enable = true;

  home.username = "mikeyobrien";
  home.homeDirectory = "/Users/mikeyobrien";
  home.file.".emacs.d/init.el".text = ''
    (load "default.el")
  '';

  home.packages = with pkgs; [
    fish
    htop

    ripgrep
    fzf
    fd
    bat
    diff-so-fancy
    gopls
    direnv
  ];

  programs.bat.enable = true;
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.direnv.enable = true;

  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    withPython3 = true;
    # extraConfig = builtins.readFile ./nvim/init.vim;
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      ".." = "cd ..";
    };
    shellAbbrs = {
      tf = "terraform";
      gc = "git commit";
      gco = "git checkout";
      gcm = "git commit -m";
      dsf = "git diff --color | diff-so-fancy";
      gs = "git status";
    };
    plugins = [
      {
        name = "bass";
        src = pkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "50eba266b0d8a952c7230fca1114cbc9fbbdfbd4";
          sha256 = "0ppmajynpb9l58xbrcnbp41b66g7p0c9l2nlsvyjwk6d16g4p4gy";
        };
      }

      {
        name = "foreign-env";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-foreign-env";
          rev = "dddd9213272a0ab848d474d0cbde12ad034e65bc";
          sha256 = "00xqlyl3lffc5l0viin1nyp819wf81fncqyz87jx8ljjdhilmgbs";
        };
      }

      {
        name = "fzf.fish";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "e0b0cbb649c7bfe4a7b490a4ab7285e797a513e6";
          sha256 = "sha256-TFzFrvxBAQAhg/3C8UIM4c/LQdu/zICEm10vdX0oULM=";
        };
      }

      {
        name = "agnoster";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "theme-agnoster";
          rev = "43860ce1536930bca689470e26083b0a5b7bd6ae";
          sha256 = "16k94hz3s6wayass6g1lhlcjmbpf2w8mzx90qrrqp120h80xwp25";
        };
      }

      {
        name = "fish-ssh-agent";
        src = pkgs.fetchFromGitHub {
          owner = "danhper";
          repo = "fish-ssh-agent";
          rev = "fd70a2afdd03caf9bf609746bf6b993b9e83be57";
          sha256 = "1fvl23y9lylj4nz6k7yfja6v9jlsg8jffs2m5mq0ql4ja5vi5pkv";
        };
      }

    ];

    loginShellInit = ''
      if test -e $HOME/.nix-profile/etc/profile.d/nix-daemon.sh
        fenv source $HOME/.nix-profile/etc/profile.d/nix-daemon.sh
      end

      if test -e $HOME/.nix-profile/etc/profile.d/nix.sh
        fenv source $HOME/.nix-profile/etc/profile.d/nix.sh
      end
    '';
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

  xdg.configFile."fish/conf.d/plugin-bobthefish.fish".text = lib.mkAfter ''
    for f in $plugin_dir/*.fish
      source $f
    end
  '';

  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  home.stateVersion = "21.03";
}
