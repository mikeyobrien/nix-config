{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.emacs;
in {
  options.modules.emacs.enable = mkEnableOption "emacs"; 

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sqlite
      xdot
      emacs-all-the-icons-fonts
      fd
      imagemagick
      python-language-server
      zstd
      gcc
      gopls
      python
    ];

    homeManagerPrograms.emacs = {
      enable = true;
      package = pkgs.emacsGcc;
    };

    services.emacs.enable = true;
  };
}
