{ config, lib, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      ".." = "cd ..";
      laht = "ls -laht";
      vim  = "nvim";
      vi   = "nvim";
    };
    shellAbbrs = {
      k = "kubectl";
      tf = "terraform";
      mk = "minikube kubectl --";
      gc = "git commit";
      gco = "git checkout";
      gcm = "git commit -m";
      dsf = "git diff --color | diff-so-fancy";
      gs = "git status";
      dev-us = "aws --profile saas-dataeng-dev";
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
        name = "fish-ssh-agent";
        src = pkgs.fetchFromGitHub {
          owner = "danhper";
          repo = "fish-ssh-agent";
          rev = "fd70a2afdd03caf9bf609746bf6b993b9e83be57";
          sha256 = "1fvl23y9lylj4nz6k7yfja6v9jlsg8jffs2m5mq0ql4ja5vi5pkv";
        };
      }

    ];

    interactiveShellInit = ''
      set -g fish_greeting ""
      ${pkgs.thefuck}/bin/thefuck --alias | source
    '';

    loginShellInit = ''
      if test -e $HOME/.nix-profile/etc/profile.d/nix-daemon.sh
        fenv source $HOME/.nix-profile/etc/profile.d/nix-daemon.sh
      end

      if test -e $HOME/.nix-profile/etc/profile.d/nix.sh
        fenv source $HOME/.nix-profile/etc/profile.d/nix.sh
      end
    '';
  };
}
