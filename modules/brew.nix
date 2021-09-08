{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.brew;
in {
  options.modules.brew = {
    enable = mkEnableOption "Homebrew";
    taps = mkOption {
      type = types.listOf types.str;
      default = [ 
        "homebrew/core"
        "homebrew/cask"
        "homebrew/bundle"
        "homebrew/services"
        "d12frosted/emacs-plus"
      ];
    };
    brews = mkOption {
      type = types.listOf types.str;
      default = [
      ];
    };
    casks = mkOption {
      type = types.listOf types.str;
      default = [ "firefox" ];
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    homebrew.enable = true;
    homebrew.autoUpdate = true;
    homebrew.cleanup = "none";
    homebrew.global.brewfile = true;
    homebrew.global.noLock = true;
    homebrew.taps = cfg.taps;
    homebrew.brews = cfg.brews;
    homebrew.casks = cfg.casks;
    homebrew.extraConfig = cfg.extraConfig;
  };
}
