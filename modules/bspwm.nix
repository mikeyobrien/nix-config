{ options, config, lib, pkgs, home-manager, ... }:

with lib;
let cfg = config.modules.bspwm;
in {
  options.modules.bspwm = {
    enable = mkEnableOption "bspwm";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lightdm
    ];

    services = {
      xserver = {
        enable = true;
        displayManager = {
          defaultSession = "none+bspwm";
          lightdm.enable = true;
          lightdm.greeters.mini.enable = true;
          lightdm.greeters.mini.user = "mikeyobrien";
        };
        windowManager.bspwm.enable = true;
      };
    };

    home.configFile."sxhkd".source = ../home/configs/sxhkd;
    home.file."bspwm"= {
      source = ../home/configs/bspwm;
      recursive = true;
    };
  };
}
