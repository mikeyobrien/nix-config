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

    home.packages = with pkgs; [
      xst
      rofi
    ];

    homeManagerServices.sxhkd = {
      enable = true;
      extraConfig = builtins.readFile ../home/configs/sxhkd/sxhkdrc;
    };

    services = {
      xserver = {
        enable = true;
        displayManager = {
          defaultSession = "none+bspwm";
          lightdm.enable = true;
        };
        windowManager.bspwm.enable = true;
      };
    };

    home.file.".Xresources".source = ../home/configs/xresources;
    home.configFile."bspwm" = {
      source = ../home/configs/bspwm;
      recursive = true;
    };
  };
}
