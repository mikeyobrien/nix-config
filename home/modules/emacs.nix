{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.emacs;
in {
  options.modules.emacs.enable = mkEnableOption "emacs"; 

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sqlite
      emacs-all-the-icons-fonts
      fd
      imagemagick
      zstd
    ];

    homeManagerPrograms.emacs = {
      enable = true;
      extraPackages = epkg: [
        epkg.evil-collection
      ];
    };

    services.emacs.enable = true;
    home.file.".doom.d" = {
      source = ../doom.d;
      recursive = true;
      onChange = builtins.readFile ../../doom-setup.sh;
    }; 
  };
}
