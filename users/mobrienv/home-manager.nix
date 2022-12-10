{ config, pkgs, ... }:

{
  home.username = "mobrienv";
  home.homeDirectory = "/home/mobrienv";

  xdg.configFile."i3/config".text = builtins.readFile ./i3;

  programs.alacritty = {
    enable = true;
    settings = {
     font.size = 20;
    };
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      "xrandr-macbook" = "xrandr -s 3456x2160";
      "xrandr-docked" = "xrandr -s 3840x2160";
    };
  };

  home.packages = with pkgs; [
    firefox
    ((emacsPackagesFor emacsUnstable).emacsWithPackages (epkgs:
        with epkgs;
        # Use Nix to manage packages with non-trivial userspace dependencies.
        [
          emacsql
          emacsql-sqlite
          pdf-tools
          org-pdftools
          vterm
        ]))
    jq
    rofi
    fd
    ripgrep

    # rust
    cargo
    rustc
    rust-analyzer
  ];

  programs.git = {
    enable = true;
    userName = "mobrienv";
    userEmail = "hmobrienv@gmail.com";
    extraConfig = {
      safe.directory = [ "*" ];
    };
  };

  programs.direnv = {
    enable = true;
  };

  home.stateVersion = "22.05";
  programs.home-manager.enable = true;
}
