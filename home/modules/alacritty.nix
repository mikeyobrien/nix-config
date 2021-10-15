{ options, config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.alacritty;
in {
  options.modules.alacritty.enable = mkEnableOption "alacritty";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      alacritty
    ];

    homeManagerPrograms.alacritty = {
      enable = true;
      settings = {
        font = {
          normal = {
            family = "Iosevka";
            style = "Medium";
          };
          bold = {
            family = "Iosevka";
            style = "Heavy";
          };
          italic = {
            family = "Iosevka";
            style = "Light Italic";
          };
          size = 12.0;
        };
        mouse = {
          hide_when_type = true;
        };
      };
    };
  };
}
