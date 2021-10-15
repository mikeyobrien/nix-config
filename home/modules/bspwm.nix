{ options, config, lib, pkgs, ... }:

with lib;
let cfg = config.programs.bspwm;
in {
  options.programs.bspwm = {
    enable = mkEnableOption "bspwm";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lightdm
      alacritty
    ];

    services = {
      xserver = {
        enable = true;
        displayManager = {
          defaultSession = "none+bspwm";
          lightdm.enable = true;
          lightdm.greeters.mini.enable = true;
        };
        windowManager.bspwm.enable = true;
      };
    };
    home.file.".config/sxhkd/sxhkdrc".source = configs/sxhkd/sxhkdrc;
    home.file.".config/bspwm/bspwmrc".source = configs/bspwm/bspwmrc;

  };
}
