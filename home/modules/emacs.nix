{ config, lib, pkgs, ... }:
with lib;
let cfg = config.programs.emacs;
in {
  options.programs.emacs = {
    doomDir = mkOption {
      type = types.str;
      default = "$HOME/.doom.d";
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      DOOMDIR = cfg.doomDir;
    };

    # doom emacs dependencies
    home.packages = with pkgs; [
      gopls
      sbcl
      clojure-lsp
      emacs-all-the-icons-fonts
    ];
  };
}
